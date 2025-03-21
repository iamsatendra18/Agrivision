import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class TraderNotificationScreen extends StatelessWidget {
  final List<Map<String, String>> notifications = [
    {
      "title": "🌾 Weather Alert",
      "message": "Heavy rain expected tomorrow. Protect your crops!",
      "time": "1 hour ago"
    },
    {
      "title": "📈 Market Price Update",
      "message": "Tomato prices have increased by 15%. Check market trends.",
      "time": "3 hours ago"
    },
    {
      "title": "🛒 New Buyer Interest",
      "message": "A buyer is interested in your wheat listing.",
      "time": "Yesterday"
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: Text(
          'Trader Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[700],
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft), // Back button
          onPressed: () {
            Navigator.pop(context); // Navigate back to Trader Home Screen
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

  /// Empty state UI when there are no notifications
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.bellOff, size: 80, color: Colors.grey[400]),
          SizedBox(height: 10),
          Text(
            "No Notifications Available",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600]),
          ),
          SizedBox(height: 5),
          Text(
            "Stay tuned for updates and alerts!",
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
    if (title.contains("Weather")) {
      return LucideIcons.cloudRain; // Weather alerts
    } else if (title.contains("Market")) {
      return LucideIcons.trendingUp; // Market price updates
    } else if (title.contains("Buyer")) {
      return LucideIcons.shoppingCart; // Buyer interest
    } else {
      return LucideIcons.bell; // General notifications
    }
  }
}
