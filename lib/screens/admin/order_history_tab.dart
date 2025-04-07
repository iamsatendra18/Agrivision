import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class OrderHistoryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text('Admin Order History'),
        backgroundColor: Color(0xFF2E7D32),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final orders = snapshot.data!.docs;

          // Count orders by status
          int pending = 0, delivered = 0, cancelled = 0;
          for (var order in orders) {
            final status = order['status']?.toString().toLowerCase() ?? '';
            if (status == 'pending') pending++;
            else if (status == 'delivered') delivered++;
            else if (status == 'cancelled') cancelled++;
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Summary',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatusCard('Pending', pending, Colors.orange),
                    _buildStatusCard('Delivered', delivered, Colors.green),
                    _buildStatusCard('Cancelled', cancelled, Colors.red),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),
                const Text(
                  'All Orders',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      final data = order.data() as Map<String, dynamic>;
                      final orderId = order.id;
                      final status = data['status'] ?? 'Pending';
                      final totalAmount = data['totalAmount'] ?? 0;
                      final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
                      final userId = data['userId'];
                      final items = data['items'] as List<dynamic>? ?? [];

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
                        builder: (context, userSnap) {
                          String userName = 'Unknown User';
                          if (userSnap.hasData) {
                            final userData = userSnap.data!.data() as Map<String, dynamic>?;
                            if (userData != null) {
                              userName = userData['fullName'] ?? 'Unnamed';
                            }
                          }

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            elevation: 4,
                            child: ListTile(
                              leading: const Icon(Icons.receipt_long, color: Colors.green),
                              title: Text("Order #$orderId"),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("👤 Buyer: $userName"),
                                  Text("🛒 Items: ${items.length}, ₹$totalAmount"),
                                  if (timestamp != null)
                                    Text("🗓️ ${DateFormat.yMMMd().add_jm().format(timestamp)}"),
                                ],
                              ),
                              trailing: _statusChip(status),
                              onTap: () {
                                // 🔄 Navigate to order detail if needed
                                // Navigator.push(context, MaterialPageRoute(
                                //   builder: (_) => OrderDetailsScreen(orderData: data),
                                // ));
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(String status, int count, Color color) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(status, style: const TextStyle(fontSize: 18, color: Colors.white)),
            const SizedBox(height: 10),
            Text('$count',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'delivered':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(status),
      backgroundColor: color.withOpacity(0.2),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
    );
  }
}
