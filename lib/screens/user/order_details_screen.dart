import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const OrderDetailsScreen({Key? key, required this.orderData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productName = orderData['itemName'] ?? 'Product';
    final quantity = orderData['itemQuantity'] ?? 'N/A';
    final subtotal = orderData['totalAmount'] - 30;
    final deliveryCharge = 30.0;
    final totalAmount = orderData['totalAmount'] ?? 0.0;
    final note = orderData['note'] ?? 'No notes added';
    final lat = orderData['latitude'];
    final lng = orderData['longitude'];
    final LatLng latLng = LatLng(lat, lng);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Details"),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Product Info Section
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                title: Text(productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Quantity: $quantity"),
                trailing: const Text("Pending", style: TextStyle(color: Colors.orange)),
              ),
            ),
            const SizedBox(height: 20),

            // Payment Breakdown
            _buildPriceRow("Subtotal", subtotal),
            _buildPriceRow("Delivery Charge", deliveryCharge),
            _buildPriceRow("Total Payment", totalAmount, bold: true),

            const SizedBox(height: 20),

            // Order Note
            const Text("Order Note:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(note),

            const SizedBox(height: 20),

            // Shipping Location
            const Text("Shipping To:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: latLng,
                  zoom: 15,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('deliveryLocation'),
                    position: latLng,
                  ),
                },
                zoomControlsEnabled: false,
                liteModeEnabled: true,
              ),
            ),

            const SizedBox(height: 30),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Need Help!"),
                        content: const Text("For assistance please contact our support at:\n📧 satendrakushwaha2021@gmail.com"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Close"),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text("Need Help"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    // TODO: Implement cancel logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Order canceled (not implemented yet)")),
                    );
                  },
                  child: const Text("Cancel Order"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text("₹${value.toStringAsFixed(2)}", style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}