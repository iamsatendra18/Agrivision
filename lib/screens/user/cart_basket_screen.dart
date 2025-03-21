import 'package:flutter/material.dart';

class CartBasketScreen extends StatefulWidget {
  const CartBasketScreen({super.key});

  @override
  _CartBasketScreenState createState() => _CartBasketScreenState();
}

class _CartBasketScreenState extends State<CartBasketScreen> {
  // Sample cart data (Replace with real data from the database)
  List<Map<String, dynamic>> cartItems = [
    {"name": "Organic Tomatoes", "price": 40, "quantity": 1, "image": "assets/tomatoes.png"},
    {"name": "Fresh Spinach", "price": 30, "quantity": 2, "image": "assets/spinach.png"},
    {"name": "Golden Potatoes", "price": 25, "quantity": 3, "image": "assets/potatoes.png"},
  ];

  // Function to increase quantity (Max: 15)
  void increaseQuantity(int index) {
    setState(() {
      if (cartItems[index]['quantity'] < 15) {
        cartItems[index]['quantity']++;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Maximum quantity is 15!")),
        );
      }
    });
  }

  // Function to decrease quantity (Min: 1)
  void decreaseQuantity(int index) {
    setState(() {
      if (cartItems[index]['quantity'] > 1) {
        cartItems[index]['quantity']--;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Minimum quantity is 1!")),
        );
      }
    });
  }

  // Function to remove item
  void removeItem(int index) {
    setState(() {
      cartItems.removeAt(index);
    });
  }

  // Function to calculate total price
  double getTotalPrice() {
    return cartItems.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));
  }

  // Function to save cart
  void saveCart() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Cart saved successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart Basket'),
        backgroundColor: Colors.green[700], // Agriculture theme
        centerTitle: true,
      ),
      body: Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1: Cart Products
              Text(
                '🛒 Cart Products',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[700],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                flex: 3,
                child: cartItems.isEmpty
                    ? Center(
                  child: Text(
                    "Your cart is empty",
                    style: TextStyle(fontSize: 18, color: Colors.brown[600]),
                  ),
                )
                    : ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage(item["image"]),
                          radius: 25,
                        ),
                        title: Text(
                          item["name"],
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          "₹${item["price"]} x ${item["quantity"]} = ₹${item["price"] * item["quantity"]}",
                          style: const TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                              onPressed: () => decreaseQuantity(index),
                            ),
                            Text(
                              item["quantity"].toString(),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                              onPressed: () => increaseQuantity(index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => removeItem(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              // Section 2: Total Amount & Proceed Button
              if (cartItems.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💰 Total Amount',
                      style: TextStyle(
                        fontSize: 22,
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
                            "Total: ₹${getTotalPrice()}",
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Navigate to Checkout
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
                  ],
                ),

              const SizedBox(height: 20),

              // Section 3: Save Cart Button
              if (cartItems.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💾 Save Cart',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown[700],
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: saveCart,
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text('Save Cart'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        textStyle: const TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
