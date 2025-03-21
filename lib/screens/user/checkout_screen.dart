import 'package:flutter/material.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Checkout'),
        backgroundColor: Colors.green[700], // Agriculture-themed color
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/agrivision_logo.png'),
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 20),
                Text(
                  'AgriVision Checkout',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[700],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Secure your order and support sustainable farming!',
                  style: TextStyle(fontSize: 16, color: Colors.brown[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.shopping_cart, color: Colors.green[700]),
                          title: const Text('Items in Cart'),
                          subtitle: const Text('3 Items - ₹1200'),
                        ),
                        const Divider(),
                        ListTile(
                          leading: Icon(Icons.delivery_dining, color: Colors.green[700]),
                          title: const Text('Delivery Address'),
                          subtitle: const Text('Village Road, Agri Farm, India'),
                        ),
                        const Divider(),
                        ListTile(
                          leading: Icon(Icons.payment, color: Colors.green[700]),
                          title: const Text('Payment Method'),
                          subtitle: const Text('UPI / Debit Card / Net Banking'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    // Add checkout function
                  },
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                  label: const Text('Confirm & Pay'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    // Add cancel function
                  },
                  child: const Text(
                    'Cancel Order',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
