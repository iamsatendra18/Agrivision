import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class TraderOrderScreen extends StatelessWidget {
  final List<Map<String, dynamic>> orders = [
    {
      "product": "🌾 Wheat",
      "quantity": "100 Kg",
      "buyer": "Narayan",
      "status": "Pending",
      "icon": LucideIcons.wheat,
    },
    {
      "product": "🍏 Apples",
      "quantity": "50 Kg",
      "buyer": "Satendra",
      "status": "Delivered",
      "icon": LucideIcons.apple,
    },
    {
      "product": "🥦 Spinach",
      "quantity": "30 Bunches",
      "buyer": "Krish",
      "status": "Processing",
      "icon": LucideIcons.leaf,
    },
    {
      "product": "🥛 Dairy Milk",
      "quantity": "200 Liters",
      "buyer": "Farm Fresh Ltd.",
      "status": "Shipped",
      "icon": LucideIcons.milk,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: Text(
          'My Product Orders',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[700],
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft), // Back button
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
      ),
      body: orders.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return _buildOrderCard(orders[index]);
        },
      ),
    );
  }

  /// UI when there are no orders
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.packageSearch, size: 80, color: Colors.grey[400]),
          SizedBox(height: 10),
          Text(
            "No Orders Yet",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600]),
          ),
          SizedBox(height: 5),
          Text(
            "Your orders will appear here when customers make a purchase.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  /// Order Card Widget
  Widget _buildOrderCard(Map<String, dynamic> order) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.symmetric(vertical: 10),
      color: Colors.white,
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.green[100],
            shape: BoxShape.circle,
          ),
          child: Icon(
            order["icon"] as IconData,
            color: Colors.green[700],
            size: 30,
          ),
        ),
        title: Text(
          order["product"] ?? '',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Quantity: ${order["quantity"]}",
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
            Text(
              "Buyer: ${order["buyer"]}",
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
            Text(
              "Status: ${order["status"]}",
              style: TextStyle(
                fontSize: 14,
                color: _getStatusColor(order["status"] ?? ''),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Function to determine order status color
  Color _getStatusColor(String status) {
    switch (status) {
      case "Pending":
        return Colors.orange;
      case "Processing":
        return Colors.blue;
      case "Shipped":
        return Colors.purple;
      case "Delivered":
        return Colors.green;
      default:
        return Colors.black;
    }
  }
}
