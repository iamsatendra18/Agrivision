import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'order_details_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  String? userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('User not logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders', style: TextStyle(fontSize: screenWidth * 0.05)),
        backgroundColor: Colors.green[700],
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: userId)
            .orderBy('orderedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No orders found."));
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(screenWidth * 0.03),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final doc = orders[index];
              final data = doc.data() as Map<String, dynamic>;
              final status = data['status'] ?? 'Pending';
              final itemCount = (data['items'] as List?)?.length ?? 0;
              final totalAmount = (data['totalAmount'] ?? 0).toDouble();
              final timestamp = data['orderedAt'] as Timestamp?;
              final date = timestamp?.toDate();

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: 10),
                  title: Text(
                    "Order • $itemCount item${itemCount > 1 ? 's' : ''}",
                    style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.w500),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Status: $status",
                        style: TextStyle(
                          color: _getStatusColor(status),
                          fontSize: screenWidth * 0.04,
                        ),
                      ),
                      Text("Total: ₹${totalAmount.toStringAsFixed(2)}", style: TextStyle(fontSize: screenWidth * 0.04)),
                      if (date != null)
                        Text(
                          "Date: ${date.day}/${date.month}/${date.year}",
                          style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.grey),
                        ),
                    ],
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: screenWidth * 0.04),
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
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
