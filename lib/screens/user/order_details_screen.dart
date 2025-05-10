import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const OrderDetailsScreen({Key? key, required this.orderData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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
        title: Text("Order Details", style: TextStyle(fontSize: screenWidth * 0.05)),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenWidth * 0.03),
        child: ListView(
          children: [
            Text("🛒 Products Ordered", style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.045)),
            SizedBox(height: screenWidth * 0.02),
            ...items.map((item) {
              final name = item['name'] ?? 'Product';
              final qty = item['quantity'] ?? 1;
              final price = item['price'] ?? 0.0;
              final total = qty * price;
              final imageUrl = item['imageUrl'] ?? '';

              return ListTile(
                leading: imageUrl.toString().isNotEmpty
                    ? (imageUrl.toString().startsWith("http")
                    ? Image.network(
                  imageUrl,
                  width: screenWidth * 0.12,
                  height: screenWidth * 0.12,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                )
                    : Image.asset(
                  imageUrl,
                  width: screenWidth * 0.12,
                  height: screenWidth * 0.12,
                  fit: BoxFit.cover,
                ))
                    : Icon(Icons.image_not_supported, size: screenWidth * 0.1),
                title: Text(name, style: TextStyle(fontWeight: FontWeight.w500, fontSize: screenWidth * 0.045)),
                subtitle: Text("Qty: $qty x ₹$price", style: TextStyle(fontSize: screenWidth * 0.035)),
                trailing: Text("₹${total.toStringAsFixed(2)}", style: TextStyle(fontWeight: FontWeight.w600, fontSize: screenWidth * 0.04)),
              );
            }).toList(),

            const Divider(),
            _buildPriceRow("Subtotal", subtotal, screenWidth),
            _buildPriceRow("Delivery Charge", deliveryCharge, screenWidth),
            _buildPriceRow("Total", totalAmount, screenWidth, bold: true),

            SizedBox(height: screenWidth * 0.05),
            Text("📝 Order Note", style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.045)),
            SizedBox(height: screenWidth * 0.015),
            Text(note, style: TextStyle(color: Colors.black87, fontSize: screenWidth * 0.04)),

            SizedBox(height: screenWidth * 0.05),
            Text("📍 Shipping Location", style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.045)),
            SizedBox(height: screenWidth * 0.02),
            SizedBox(
              height: screenWidth * 0.5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(target: latLng, zoom: 15),
                  markers: {
                    Marker(markerId: MarkerId('deliveryLocation'), position: latLng),
                  },
                  zoomControlsEnabled: false,
                  liteModeEnabled: true,
                ),
              ),
            ),

            SizedBox(height: screenWidth * 0.08),
            Center(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06, vertical: screenWidth * 0.035),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  side: BorderSide(color: Colors.green.shade700),
                  backgroundColor: Colors.white,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (_) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: screenWidth * 0.06, horizontal: screenWidth * 0.05),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.info, color: Colors.green, size: screenWidth * 0.09),
                          SizedBox(height: screenWidth * 0.02),
                          Text("Need Help!",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.05)),
                          SizedBox(height: screenWidth * 0.02),
                          Text(
                            "For any assistance please contact our support at:",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: screenWidth * 0.038),
                          ),
                          SizedBox(height: screenWidth * 0.015),
                          Text(
                            "📧 satendrakushwaha2021@gmail.com",
                            style: TextStyle(fontSize: screenWidth * 0.038),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: screenWidth * 0.04),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.06,
                                vertical: screenWidth * 0.025,
                              ),
                            ),
                            child: Text("Close", style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.support_agent, color: Colors.green, size: screenWidth * 0.05),
                label: Text("Need Help", style: TextStyle(color: Colors.green, fontSize: screenWidth * 0.045)),
              ),
            ),
            SizedBox(height: screenWidth * 0.05),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double value, double screenWidth, {bool bold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.01),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                  fontSize: screenWidth * 0.04)),
          Text("₹${value.toStringAsFixed(2)}",
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                  fontSize: screenWidth * 0.04)),
        ],
      ),
    );
  }
}
