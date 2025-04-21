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

  // void _openMap() {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text("📍 Map opened for location confirmation")),
  //   );
  // }

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
        shippingAddressController.text =
        "Lat: ${result.latitude}, Lng: ${result.longitude}";
      });
    }
  }

  void _payWithEsewa(String note, String address, double total) async {

    try {
      EsewaFlutterSdk.initPayment(
        esewaConfig: EsewaConfig(
            clientId: _clientId,
            secretId: _secretKey,
            environment: Environment.test),
        onPaymentSuccess: (EsewaPaymentSuccessResult data) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Payment Successful!}")),
          );
          _saveOrderToFirestore(note, address, total, 'eSewa');
          },
        onPaymentFailure: ( data) {
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
            productPrice: widget.totalAmount.toString(),
            callbackUrl: 'https://yourdomain.com/callback'),
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

    final newOrder = {
      'userId': userId,
      'items': widget.cartItems,
      'note': note,
      'deliveryAddress': address,
      'latitude': widget.latitude,
      'longitude': widget.longitude,
      'totalAmount': total,
      'paymentMethod': paymentMethod,
      'status': 'Pending',
      'timestamp': Timestamp.now(),
    };

    await FirebaseFirestore.instance.collection('orders').add(newOrder);
    await _clearCart(userId); // ✅ Clear cart after order

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Order placed successfully!")),
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
      debugPrint("Saved Note: $note");
      debugPrint("Saved Address: $address");
    }
  }

  @override
  Widget build(BuildContext context) {
    double total = widget.totalAmount + deliveryCharge;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirm Your Order"),
        backgroundColor: Colors.green[700],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("📝 Note:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("📍 Shipping to:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                ],
              ),  TextButton(
                onPressed: _openMap,
                child: const Text("Proceed"),
              ),
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
              const Text("💳 Choose Payment:", style: TextStyle(fontSize: 18)),
              DropdownButtonFormField<String>(
                value: selectedPayment,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'Cash on Delivery', child: Text('Cash on Delivery')),
                  DropdownMenuItem(value: 'eSewa', child: Text('eSewa')),
                ],
                onChanged: (val) {
                  setState(() => selectedPayment = val!);
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _placeOrder,
                child: const Text("🛒 Place Order"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: _saveDraft,
                child: const Text("💾 Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
