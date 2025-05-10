import 'package:esewa_flutter_sdk/esewa_config.dart';
import 'package:esewa_flutter_sdk/esewa_flutter_sdk.dart';
import 'package:esewa_flutter_sdk/esewa_payment.dart';
import 'package:esewa_flutter_sdk/esewa_payment_success_result.dart';
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
  final String _clientId = "JB0BBQ4aD0UqIThFJwAKBgAXEUkEGQUBBAwdOgABHD4DChwUAB0R";
  final String _secretKey = "BhwIWQQADhIYSxILExMcAgFXFhcOBwAKBgAXEQ==";
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
      print("Error loading cart: $e");
    }
  }

  Future<void> _openPaymentScreen() async {
    try {
      EsewaFlutterSdk.initPayment(
        esewaConfig: EsewaConfig(
            clientId: _clientId,
            secretId: _secretKey,
            environment: Environment.test),
        onPaymentSuccess: (EsewaPaymentSuccessResult data) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Payment Successful!")),
          );
        },
        onPaymentFailure: (data) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Payment Failed: ${data.message}")),
          );
        },
        onPaymentCancellation: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Payment Cancelled")),
          );
        },
        esewaPayment: EsewaPayment(
            productId: "ORDER_${DateTime.now().millisecondsSinceEpoch}",
            productName: 'Test Product',
            productPrice: totalAmount.toString(),
            callbackUrl: 'https://yourdomain.com/callback'),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _cancelOrder() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cancel Order"),
        content: const Text("Are you sure you want to cancel your order?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text("Yes, Cancel"),
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
        const SnackBar(content: Text("🗑️ Order cancelled and cart cleared.")),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        RoutesName.navigationMenu,
            (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to cancel order: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/agrivision_logo.png'),
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 20),
                Text(
                  'AgriVision Checkout',
                  style: TextStyle(
                    fontSize: screenWidth * 0.055,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[700],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Secure your order and support sustainable farming!',
                  style: TextStyle(fontSize: screenWidth * 0.042, color: Colors.brown[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(screenWidth * 0.045),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.shopping_cart, color: Colors.green[700], size: screenWidth * 0.07),
                          title: Text('Items in Cart', style: TextStyle(fontSize: screenWidth * 0.045)),
                          subtitle: Text('$totalItems Items - ₹${totalAmount.toStringAsFixed(2)}'),
                        ),
                        const Divider(),
                        ListTile(
                          leading: Icon(Icons.delivery_dining, color: Colors.green[700], size: screenWidth * 0.07),
                          title: Text('Delivery Address', style: TextStyle(fontSize: screenWidth * 0.045)),
                          subtitle: const Text('Village Road, Agri Farm, Nepal'),
                        ),
                        const Divider(),
                        InkWell(
                          onTap: _openPaymentScreen,
                          child: ListTile(
                            leading: Icon(Icons.payment, color: Colors.green[700], size: screenWidth * 0.07),
                            title: Text('Payment Method', style: TextStyle(fontSize: screenWidth * 0.045)),
                            subtitle: const Text('Tap to choose Cash on Delivery / FonePay / eSewa'),
                            trailing: Icon(Icons.arrow_forward_ios, size: screenWidth * 0.04, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _openPaymentScreen,
                    icon: const Icon(Icons.check_circle, color: Colors.white),
                    label: const Text('Confirm & Pay'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.1,
                        vertical: screenWidth * 0.035,
                      ),
                      textStyle: TextStyle(fontSize: screenWidth * 0.045),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: _cancelOrder,
                  child: Text(
                    'Cancel Order',
                    style: TextStyle(color: Colors.red, fontSize: screenWidth * 0.043),
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
