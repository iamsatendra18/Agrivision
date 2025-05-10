import 'package:esewa_flutter_sdk/esewa_config.dart';
import 'package:esewa_flutter_sdk/esewa_flutter_sdk.dart';
import 'package:esewa_flutter_sdk/esewa_payment.dart';
import 'package:esewa_flutter_sdk/esewa_payment_success_result.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'map_screen.dart';

class CheckoutDetailsScreen extends StatefulWidget {
  final double totalAmount;
  final int itemCount;
  final List<Map<String, dynamic>> cartItems;
  final double latitude;
  final double longitude;
  final VoidCallback? onOrderPlaced;

  const CheckoutDetailsScreen({
    super.key,
    required this.totalAmount,
    required this.itemCount,
    required this.cartItems,
    required this.latitude,
    required this.longitude,
    this.onOrderPlaced,
  });

  @override
  State<CheckoutDetailsScreen> createState() => _CheckoutDetailsScreenState();
}

class _CheckoutDetailsScreenState extends State<CheckoutDetailsScreen> {
  final TextEditingController noteController = TextEditingController();
  final TextEditingController shippingAddressController = TextEditingController();
  final String _clientId = "JB0BBQ4aD0UqIThFJwAKBgAXEUkEGQUBBAwdOgABHD4DChwUAB0R";
  final String _secretKey = "BhwIWQQADhIYSxILExMcAgFXFhcOBwAKBgAXEQ==";
  String selectedPayment = 'Cash on Delivery';
  double deliveryCharge = 30.0;
  LatLng? selectedLocation;

  void _openMap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(
          initialLatitude: widget.latitude,
          initialLongitude: widget.longitude,
        ),
      ),
    );

    if (result != null && result is LatLng) {
      setState(() {
        selectedLocation = result;
        shippingAddressController.text = "Lat: ${result.latitude}, Lng: ${result.longitude}";
      });
    }
  }

  void _payWithEsewa(String note, String address, double total) async {
    try {
      EsewaFlutterSdk.initPayment(
        esewaConfig: EsewaConfig(
          clientId: _clientId,
          secretId: _secretKey,
          environment: Environment.test,
        ),
        onPaymentSuccess: (EsewaPaymentSuccessResult data) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Payment Successful!")),
          );
          _saveOrderToFirestore(note, address, total, 'eSewa');
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
          productName: 'AgriVision Order',
          productPrice: widget.totalAmount.toString(),
          callbackUrl: 'https://yourdomain.com/callback',
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void _placeOrder() async {
    final note = noteController.text.trim();
    final address = shippingAddressController.text.trim();
    double total = widget.totalAmount + deliveryCharge;

    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter shipping address")),
      );
      return;
    }

    if (selectedPayment == 'Cash on Delivery') {
      _saveOrderToFirestore(note, address, total, 'Cash on Delivery');
    } else if (selectedPayment == 'eSewa') {
      _payWithEsewa(note, address, total);
    }
  }

  void _saveOrderToFirestore(String note, String address, double total, String paymentMethod) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    final traderId = widget.cartItems.isNotEmpty ? widget.cartItems[0]['traderId'] : null;

    final order = {
      'userId': userId,
      'traderId': traderId,
      'items': widget.cartItems,
      'note': note,
      'deliveryAddress': address,
      'latitude': selectedLocation?.latitude ?? widget.latitude,
      'longitude': selectedLocation?.longitude ?? widget.longitude,
      'totalAmount': total,
      'paymentMethod': paymentMethod,
      'status': 'Pending',
      'orderedAt': Timestamp.now(),
    };

    await FirebaseFirestore.instance.collection('orders').add(order);
    await _clearCart(userId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Order placed successfully!")),
    );

    if (widget.onOrderPlaced != null) {
      widget.onOrderPlaced!();
    }

    Navigator.pop(context);
  }

  Future<void> _clearCart(String userId) async {
    final cartItemsRef = FirebaseFirestore.instance
        .collection('cart')
        .doc(userId)
        .collection('items');

    final cartSnapshot = await cartItemsRef.get();
    for (var doc in cartSnapshot.docs) {
      await doc.reference.delete();
    }
  }

  void _saveDraft() {
    final note = noteController.text.trim();
    final address = shippingAddressController.text.trim();

    if (note.isEmpty || address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter note and address to save.")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("💾 Saved: Note & Address")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double total = widget.totalAmount + deliveryCharge;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirm Your Order"),
        backgroundColor: Colors.green[700],
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("📝 Note:", style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  hintText: "Write any info about your order",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              Text("📍 Shipping to:", style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold)),
              TextButton(onPressed: _openMap, child: const Text("Proceed")),
              TextField(
                controller: shippingAddressController,
                decoration: const InputDecoration(
                  hintText: "Enter delivery address",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("🧮 Subtotal:"),
                  Text("₹${widget.totalAmount.toStringAsFixed(2)}"),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("🚚 Delivery charge:"),
                  Text("₹${deliveryCharge.toStringAsFixed(2)}"),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("💰 Total:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("₹${total.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),
              Text("💳 Choose Payment:", style: TextStyle(fontSize: screenWidth * 0.045)),
              DropdownButtonFormField<String>(
                value: selectedPayment,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'Cash on Delivery', child: Text('Cash on Delivery')),
                  DropdownMenuItem(value: 'eSewa', child: Text('eSewa')),
                ],
                onChanged: (val) => setState(() => selectedPayment = val!),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _placeOrder,
                  child: const Text("🛒 Place Order"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
                    textStyle: TextStyle(fontSize: screenWidth * 0.045),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _saveDraft,
                  child: const Text("💾 Save"),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: screenWidth * 0.035),
                    textStyle: TextStyle(fontSize: screenWidth * 0.045),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
