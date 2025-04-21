import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const OrderDetailsScreen({Key? key, required this.orderData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = orderData['items'] as List<dynamic>? ?? [];
    final subtotal = (orderData['totalAmount'] ?? 0.0) - 30;
    final deliveryCharge = 30.0;
    final totalAmount = orderData['totalAmount'] ?? 0.0;
    final note = orderData['note'] ?? 'No notes added';
    final lat = (orderData['latitude'] ?? 27.700).toDouble();
    final lng = (orderData['longitude'] ?? 85.300).toDouble();
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
            const Text("🛒 Products Ordered", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ...items.map((item) {
              final name = item['name'] ?? 'Product';
              final qty = item['quantity'] ?? 1;
              final price = item['price'] ?? 0.0;
              final total = qty * price;
              return ListTile(
                title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text("Qty: $qty x ₹$price"),
                trailing: Text("₹${total.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.w600)),
              );
            }).toList(),

            const Divider(),
            _buildPriceRow("Subtotal", subtotal),
            _buildPriceRow("Delivery Charge", deliveryCharge),
            _buildPriceRow("Total", totalAmount, bold: true),

            const SizedBox(height: 20),
            const Text("📝 Order Note", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 6),
            Text(note, style: const TextStyle(color: Colors.black87)),

            const SizedBox(height: 20),
            const Text("📍 Shipping Location", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(target: latLng, zoom: 15),
                  markers: {
                    Marker(markerId: const MarkerId('deliveryLocation'), position: latLng),
                  },
                  zoomControlsEnabled: false,
                  liteModeEnabled: true,
                ),
              ),
            ),

            const SizedBox(height: 30),
            Align(
              alignment: Alignment.center,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  side: BorderSide(color: Colors.green.shade700),
                  backgroundColor: Colors.white,
                  elevation: 0,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (_) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.info, color: Colors.green, size: 36),
                          const SizedBox(height: 10),
                          const Text("Need Help!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          const SizedBox(height: 8),
                          const Text(
                            "For any assistance please contact our support at:",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "📧 satendrakushwaha2021@gmail.com",
                            style: TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            ),
                            child: const Text("Close", style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.support_agent, color: Colors.green),
                label: const Text("Need Help", style: TextStyle(color: Colors.green)),
              ),
            ),
            const SizedBox(height: 20),
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
          Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal, fontSize: 15)),
          Text("₹${value.toStringAsFixed(2)}", style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal, fontSize: 15)),
        ],
      ),
    );
  }
}
