import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  void removeItem(DocumentSnapshot itemDoc) {
    itemDoc.reference.delete();
  }

  void saveCart() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Cart saved successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

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
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final cartItems = snapshot.data!.docs;

          if (cartItems.isEmpty) {
            return Center(child: Text("🛒 Your cart is empty"));
          }

          double total = cartItems.fold(0, (sum, doc) {
            final data = doc.data() as Map<String, dynamic>;
            return sum + (data['price'] * data['quantity']);
          });

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
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index].data() as Map<String, dynamic>;
                        final doc = cartItems[index];

                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: item['imageUrl'] != ""
                                  ? NetworkImage(item['imageUrl'])
                                  : AssetImage('assets/agrivision_logo.png') as ImageProvider,
                              radius: 25,
                            ),
                            title: Text(item["name"],
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                            subtitle: Text(
                              "₹${item["price"]} x ${item["quantity"]} = ₹${item["price"] * item["quantity"]}",
                              style: const TextStyle(fontSize: 16, color: Colors.black54),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                  onPressed: () => decreaseQuantity(doc),
                                ),
                                Text(item["quantity"].toString(),
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                                  onPressed: () => increaseQuantity(doc),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => removeItem(doc),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // TOTAL & BUTTONS
                  const SizedBox(height: 10),
                  Text('💰 Total Amount',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.brown[700])),
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
                        Text("Total: ₹${total.toStringAsFixed(2)}",
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Implement checkout logic
                          },
                          icon: const Icon(Icons.shopping_cart_checkout, color: Colors.white),
                          label: const Text('Proceed'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            textStyle: const TextStyle(fontSize: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // SAVE CART BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: saveCart,
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text('Save Cart'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        textStyle: const TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
