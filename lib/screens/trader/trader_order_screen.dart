import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TraderOrderScreen extends StatefulWidget {
  const TraderOrderScreen({super.key});

  @override
  State<TraderOrderScreen> createState() => _TraderOrderScreenState();
}

class _TraderOrderScreenState extends State<TraderOrderScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _statuses = ["All", "Pending", "Shipped", "Delivered", "Cancelled"];
  String? traderId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statuses.length, vsync: this);
    traderId = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text("My Product Orders"),
        centerTitle: true,
        backgroundColor: Colors.green[700],
        bottom: TabBar(
          controller: _tabController,
          tabs: _statuses.map((status) => Tab(text: status)).toList(),
          isScrollable: true,
          indicatorColor: Colors.white,
        ),
      ),
      body: traderId == null
          ? const Center(child: Text("\u26a0\ufe0f Trader not logged in"))
          : TabBarView(
        controller: _tabController,
        children: _statuses.map((status) => _buildOrderList(status)).toList(),
      ),
    );
  }

  Widget _buildOrderList(String statusFilter) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text("\u274c Error loading orders"));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("\ud83d\udccd No orders available."));
        }

        final traderOrders = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final items = data['items'] as List<dynamic>? ?? [];
          final status = (data['status'] ?? "").toString().toLowerCase();
          final matchesStatus = statusFilter == "All" || status == statusFilter.toLowerCase();
          final containsTraderItem = items.any((item) => item['traderId'] == traderId);
          return containsTraderItem && matchesStatus;
        }).toList();

        if (traderOrders.isEmpty) {
          return const Center(child: Text("\ud83d\udccd No orders found for your products."));
        }

        return ListView.builder(
          itemCount: traderOrders.length,
          itemBuilder: (context, index) {
            final doc = traderOrders[index];
            final data = doc.data() as Map<String, dynamic>;
            final userId = data['userId'];
            final filteredItems = (data['items'] as List<dynamic>)
                .where((item) => item['traderId'] == traderId)
                .toList();

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
              builder: (context, userSnap) {
                final userData = userSnap.data?.data() as Map<String, dynamic>? ?? {};
                final buyerName = userData['fullName'] ?? 'Unknown';

                return Column(
                  children: filteredItems.map((item) {
                    return Card(
                      margin: const EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: item['imageUrl'] != null && item['imageUrl'].toString().isNotEmpty
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item['imageUrl'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                          ),
                        )
                            : const Icon(Icons.image_not_supported),
                        title: Text(item['name'] ?? 'Unnamed Product'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Qty: ${item['quantity']} | Price: \u20b9${item['price']}"),
                            Text("Buyer: $buyerName"),
                            Text(
                              "Status: ${data['status']}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(data['status']),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            );
          },
        );
      },
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