import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'order_details_screen.dart'; // Make sure this file exists and implemented

class CartScreen extends StatelessWidget {
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('⚠️ User not logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Order History'),
        backgroundColor: Colors.green[700],
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: userId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final orders = snapshot.data!.docs;

          final pending = orders.where((doc) => (doc['status'] ?? '').toLowerCase() == 'pending').toList();
          final delivered = orders.where((doc) => (doc['status'] ?? '').toLowerCase() == 'delivered').toList();
          final canceled = orders.where((doc) => (doc['status'] ?? '').toLowerCase() == 'cancelled').toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (pending.isNotEmpty)
                _buildOrderGroup(context, "Pending Orders", pending, Colors.orange),
              if (delivered.isNotEmpty)
                _buildOrderGroup(context, "Delivered Orders", delivered, Colors.green),
              if (canceled.isNotEmpty)
                _buildOrderGroup(context, "Canceled Orders", canceled, Colors.red),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrderGroup(
      BuildContext context,
      String title,
      List<QueryDocumentSnapshot> orders,
      Color color,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.shopping_cart, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown[800]),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...orders.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final date = (data['timestamp'] as Timestamp?)?.toDate();
          final productName = data['itemName'] ?? "Product";

          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(productName),
              subtitle: Text("🗓️ ${date != null ? "${date.day}/${date.month}/${date.year}" : "N/A"}"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrderDetailsScreen(orderData: data),
                  ),
                );
              },
            ),
          );
        }).toList(),
        const SizedBox(height: 20),
      ],
    );
  }
}