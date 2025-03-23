import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agrivision/utiles/routes/routes_name.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int totalItems = 0;
  double totalAmount = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCartDetails();
  }

  Future<void> _loadCartDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final cartItems = await FirebaseFirestore.instance
          .collection('cart')
          .doc(user.uid)
          .collection('items')
          .get();

      int itemCount = cartItems.docs.length;
      double total = 0.0;

      for (var doc in cartItems.docs) {
        final data = doc.data();
        total += (data['price'] ?? 0) * (data['quantity'] ?? 1);
      }

      setState(() {
        totalItems = itemCount;
        totalAmount = total;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error loading cart: $e");
    }
  }

  Future<void> _confirmAndPay() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final itemsRef = FirebaseFirestore.instance
          .collection('cart')
          .doc(user.uid)
          .collection('items');

      final items = await itemsRef.get();

      for (var doc in items.docs) {
        await doc.reference.delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Order confirmed & paid!")),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        RoutesName.navigationMenu,
            (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to confirm order: $e")),
      );
    }
  }

  Future<void> _cancelOrder() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Cancel Order"),
        content: Text("Are you sure you want to cancel your order?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text("Yes, Cancel"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final itemsRef = FirebaseFirestore.instance
          .collection('cart')
          .doc(user.uid)
          .collection('items');

      final items = await itemsRef.get();

      for (var doc in items.docs) {
        await doc.reference.delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("🗑️ Order cancelled and cart cleared.")),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        RoutesName.navigationMenu,
            (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to cancel order: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Checkout'),
        backgroundColor: Colors.green[700],
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
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
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
                          subtitle: Text('$totalItems Items - ₹${totalAmount.toStringAsFixed(2)}'),
                        ),
                        const Divider(),
                        ListTile(
                          leading: Icon(Icons.delivery_dining, color: Colors.green[700]),
                          title: const Text('Delivery Address'),
                          subtitle: const Text('Village Road, Agri Farm, Nepal'),
                        ),
                        const Divider(),
                        ListTile(
                          leading: Icon(Icons.payment, color: Colors.green[700]),
                          title: const Text('Payment Method'),
                          subtitle: const Text('FonePay / PayPal / eSewa'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _confirmAndPay,
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
                  onPressed: _cancelOrder,
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
