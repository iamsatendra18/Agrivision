import 'package:flutter/material.dart';

class CheckoutDetailsScreen extends StatefulWidget {
  final double totalAmount;
  final int itemCount;

  const CheckoutDetailsScreen({
    Key? key,
    required this.totalAmount,
    required this.itemCount,
  }) : super(key: key);

  @override
  State<CheckoutDetailsScreen> createState() => _CheckoutDetailsScreenState();
}

class _CheckoutDetailsScreenState extends State<CheckoutDetailsScreen> {
  final TextEditingController noteController = TextEditingController();
  final TextEditingController shippingAddressController = TextEditingController();
  String selectedPayment = 'Cash on Delivery';
  double deliveryCharge = 30.0;

  void _openMap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("📍 Map opened for location confirmation")),
    );
  }

  void _placeOrder() {
    final note = noteController.text.trim();
    final address = shippingAddressController.text.trim();

    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter shipping address")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Order placed successfully!")),
    );
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
                  const Text("📍 Shipping to:",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: _openMap,
                    child: const Text("Proceed"),
                  ),
                ],
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
                  Text("₹${total.toStringAsFixed(2)}",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),

              const SizedBox(height: 20),
              const Text("💳 Choose Payment:", style: TextStyle(fontSize: 18)),
              DropdownButtonFormField<String>(
                value: selectedPayment,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'Cash on Delivery', child: Text('Cash on Delivery')),
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
