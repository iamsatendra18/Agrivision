import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderHistoryTab extends StatelessWidget {
  const OrderHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text('Admin Order History'),
        backgroundColor: Colors.green[700],
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

          int pending = 0, shipped = 0, delivered = 0, cancelled = 0;
          for (var order in orders) {
            final status = (order['status'] ?? '').toString().toLowerCase();
            if (status == 'pending') pending++;
            else if (status == 'shipped') shipped++;
            else if (status == 'delivered') delivered++;
            else if (status == 'cancelled') cancelled++;
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isSmallScreen = constraints.maxWidth < 600;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Order Summary",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _buildStatusCard('Pending', pending, Colors.orange, constraints),
                        _buildStatusCard('Shipped', shipped, Colors.blue, constraints),
                        _buildStatusCard('Delivered', delivered, Colors.green, constraints),
                        _buildStatusCard('Cancelled', cancelled, Colors.red, constraints),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text("All Orders",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          final data = order.data() as Map<String, dynamic>;
                          final orderId = order.id;
                          final items = data['items'] as List<dynamic>;
                          final userId = data['userId'];
                          final status = data['status'];
                          final totalAmount = data['totalAmount'] ?? 0;
                          final date = (data['timestamp'] as Timestamp).toDate();

                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(userId)
                                .get(),
                            builder: (context, userSnap) {
                              final userName = (userSnap.data?.data()
                              as Map<String, dynamic>?)?['fullName'] ??
                                  'Unknown';

                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                elevation: 3,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.receipt_long,
                                              color: Colors.green),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text("Order #$orderId",
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold)),
                                          ),
                                          PopupMenuButton<String>(
                                            onSelected: (val) {
                                              FirebaseFirestore.instance
                                                  .collection('orders')
                                                  .doc(orderId)
                                                  .update({'status': val});
                                            },
                                            itemBuilder: (context) =>
                                                ['Pending', 'Shipped', 'Delivered', 'Cancelled']
                                                    .map((s) =>
                                                    PopupMenuItem(value: s, child: Text(s)))
                                                    .toList(),
                                            child: Chip(
                                              label: Text(
                                                status,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: _getStatusColor(status)),
                                              ),
                                              backgroundColor:
                                              _getStatusColor(status).withOpacity(0.2),
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text("👤 Buyer: $userName"),
                                      Text("🛒 Items: ${items.length} | ₹$totalAmount"),
                                      Text(
                                        "📅 ${DateFormat.yMMMd().add_jm().format(date)}",
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(
      String label, int count, Color color, BoxConstraints constraints) {
    final isSmallScreen = constraints.maxWidth < 600;
    return Container(
      width: isSmallScreen ? double.infinity : constraints.maxWidth / 4 - 12,
      child: Card(
        color: color,
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 16, color: Colors.white)),
              const SizedBox(height: 6),
              Text('$count',
                  style: const TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'shipped':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
