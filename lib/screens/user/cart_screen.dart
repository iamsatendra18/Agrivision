import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartScreen extends StatelessWidget {
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return Scaffold(
        body: Center(child: Text('⚠️ User not logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Order History'),
        backgroundColor: Colors.green[700],
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders') // 🔁 Change your cart -> orders collection
            .where('userId', isEqualTo: userId)
            .orderBy('orderedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data?.docs ?? [];

          final pendingOrders = orders.where((doc) => doc['status'] == 'pending').toList();
          final deliveredOrders = orders.where((doc) => doc['status'] == 'delivered').toList();
          final canceledOrders = orders.where((doc) => doc['status'] == 'canceled').toList();

          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              if (pendingOrders.isNotEmpty) _buildSection("Pending Orders", pendingOrders, Colors.orange, Icons.access_time),
              if (deliveredOrders.isNotEmpty) _buildSection("Delivered Orders", deliveredOrders, Colors.green, Icons.check_circle),
              if (canceledOrders.isNotEmpty) _buildSection("Canceled Orders", canceledOrders, Colors.red, Icons.cancel),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List orders, Color color, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color),
            SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown[700]),
            ),
          ],
        ),
        SizedBox(height: 10),
        ...orders.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = data['itemName'] ?? 'Unnamed Product';
          final time = (data['orderedAt'] as Timestamp).toDate();

          return Card(
            margin: EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              title: Text(name),
              subtitle: Text("Ordered on: ${time.toString().substring(0, 16)}"),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                // Future: Add order details page if needed
              },
            ),
          );
        }),
        SizedBox(height: 20),
      ],
    );
  }
}
