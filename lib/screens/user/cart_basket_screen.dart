import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agrivision/utiles/routes/routes_name.dart';

class CartBasketScreen extends StatefulWidget {
  const CartBasketScreen({super.key});

  @override
  _CartBasketScreenState createState() => _CartBasketScreenState();
}

class _CartBasketScreenState extends State<CartBasketScreen> {
  String? userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
  }

  void increaseQuantity(DocumentSnapshot itemDoc) {
    if (itemDoc['quantity'] < 15) {
      itemDoc.reference.update({'quantity': itemDoc['quantity'] + 1});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Maximum quantity is 15!")),
      );
    }
  }

  void decreaseQuantity(DocumentSnapshot itemDoc) {
    if (itemDoc['quantity'] > 1) {
      itemDoc.reference.update({'quantity': itemDoc['quantity'] - 1});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Minimum quantity is 1!")),
      );
    }
  }

  void confirmDeleteItem(DocumentSnapshot itemDoc) {
    final item = itemDoc.data() as Map<String, dynamic>;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Delete ${item['name']}?"),
        content: const Text("Are you sure you want to remove this item from cart?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await itemDoc.reference.delete();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${item['name']} removed from cart")),
              );
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void saveCart() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Cart saved successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart Basket'),
        backgroundColor: Colors.green[700],
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('cart')
            .doc(userId)
            .collection('items')
            .orderBy('addedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final cartDocs = snapshot.data!.docs;

          if (cartDocs.isEmpty) {
            return const Center(child: Text("🛒 Your cart is empty"));
          }

          final cartItems = cartDocs.map((doc) {
            final item = doc.data() as Map<String, dynamic>;
            final price = item['price'] ?? 0;
            final quantity = item['quantity'] ?? 1;
            return {
              'name': item['name'] ?? '',
              'price': price,
              'quantity': quantity,
              'total': price * quantity,
              'image': item['imageUrl'] ?? '',
              'imageUrl': item['imageUrl'] ?? '',
              'traderId': item['traderId'] ?? '',
            };
          }).toList();

          double total = cartItems.fold(0, (sum, item) => sum + item['total']);

          return LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green[100]!, Colors.green[300]!],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: cartDocs.length,
                          itemBuilder: (context, index) {
                            final item = cartDocs[index].data() as Map<String, dynamic>;
                            final doc = cartDocs[index];
                            final imageUrl = item['imageUrl']?.toString() ?? '';

                            ImageProvider imageProvider;
                            if (imageUrl.startsWith('assets/')) {
                              imageProvider = AssetImage(imageUrl);
                            } else if (imageUrl.isNotEmpty) {
                              imageProvider = NetworkImage(imageUrl);
                            } else {
                              imageProvider = const AssetImage('assets/agrivision_logo.png');
                            }

                            return Card(
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: imageProvider,
                                  radius: screenWidth * 0.06,
                                ),
                                title: Text(
                                  item["name"] ?? '',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.045,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  "₹${item["price"] ?? 0} x ${item["quantity"] ?? 1} = ₹${(item["price"] ?? 0) * (item["quantity"] ?? 1)}",
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.04,
                                    color: Colors.black54,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                      onPressed: () => decreaseQuantity(doc),
                                    ),
                                    Text(
                                      item["quantity"].toString(),
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.045,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                                      onPressed: () => increaseQuantity(doc),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => confirmDeleteItem(doc),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '💰 Total Amount',
                        style: TextStyle(
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown[700],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total: ₹${total.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: screenWidth * 0.05,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  RoutesName.checkoutDetailsScreen,
                                  arguments: {
                                    'totalAmount': total,
                                    'itemCount': cartItems.length,
                                    'cartItems': cartItems,
                                    'latitude': 27.700,
                                    'longitude': 85.333,
                                  },
                                );
                              },
                              icon: const Icon(Icons.shopping_cart_checkout, color: Colors.white),
                              label: const Text('Proceed'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[700],
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.05,
                                  vertical: screenWidth * 0.025,
                                ),
                                textStyle: TextStyle(fontSize: screenWidth * 0.045),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: saveCart,
                          icon: const Icon(Icons.save, color: Colors.white),
                          label: const Text('Save Cart'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            padding: EdgeInsets.symmetric(vertical: screenWidth * 0.035),
                            textStyle: TextStyle(fontSize: screenWidth * 0.045),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}