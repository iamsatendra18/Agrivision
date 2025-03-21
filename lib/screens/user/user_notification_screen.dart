import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class UserNotificationScreen extends StatelessWidget {
  final List<Map<String, String>> notifications = [
    {
      "title": "🚚 Order Shipped",
      "message": "Your fresh organic tomatoes have been shipped and will arrive soon!",
      "time": "30 minutes ago"
    },
    {
      "title": "🔥 Special Offer!",
      "message": "Get 20% off on all fresh vegetables this weekend only!",
      "time": "2 hours ago"
    },
    {
      "title": "🌾 New Farm Products",
      "message": "Fresh potatoes and carrots are now available for purchase.",
      "time": "Yesterday"
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: Text(
          'Customer Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[700],
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft), // Back arrow icon
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
      ),
      body: notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return _buildNotificationCard(notifications[index]);
        },
      ),
    );
  }

  /// UI when there are no notifications
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.bellOff, size: 80, color: Colors.grey[400]),
          SizedBox(height: 10),
          Text(
            "No New Notifications",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600]),
          ),
          SizedBox(height: 5),
          Text(
            "We'll notify you about new offers, order updates, and more!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  /// Notification Card Widget
  Widget _buildNotificationCard(Map<String, String> notification) {
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
            _getNotificationIcon(notification["title"] ?? ''),
            color: Colors.green[700],
            size: 30,
          ),
        ),
        title: Text(
          notification["title"] ?? '',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification["message"] ?? '',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 5),
            Text(
              notification["time"] ?? '',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  /// Function to determine notification icon based on type
  IconData _getNotificationIcon(String title) {
    if (title.contains("Order")) {
      return LucideIcons.truck; // Order update
    } else if (title.contains("Offer") || title.contains("Discount")) {
      return LucideIcons.tag; // Special offers
    } else if (title.contains("Farm") || title.contains("New")) {
      return LucideIcons.leaf; // New product updates
    } else {
      return LucideIcons.bell; // General notifications
    }
  }
}
