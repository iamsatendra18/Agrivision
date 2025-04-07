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
  final List<String> _statuses = ["All", "Pending", "Delivered", "Cancelled"];
  final String traderId = FirebaseAuth.instance.currentUser?.uid ?? "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statuses.length, vsync: this);
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
      body: TabBarView(
        controller: _tabController,
        children: _statuses.map((status) => _buildOrderList(status)).toList(),
      ),
    );
  }

  Widget _buildOrderList(String statusFilter) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return _buildError("Error loading orders");

        final allOrders = snapshot.data?.docs ?? [];

        final filteredOrders = allOrders.where((doc) {
          final items = doc['items'] as List<dynamic>? ?? [];
          final hasTraderItems = items.any((item) => item['traderId'] == traderId);
          final status = doc['status']?.toString().toLowerCase() ?? '';
          return hasTraderItems &&
              (statusFilter == "All" || status == statusFilter.toLowerCase());
        }).toList();

        if (filteredOrders.isEmpty) return _buildEmpty();

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: filteredOrders.length,
          itemBuilder: (context, index) {
            final doc = filteredOrders[index];
            final items = (doc['items'] as List<dynamic>).where((item) => item['traderId'] == traderId).toList();
            final userId = doc['userId'];

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) return const SizedBox.shrink();
                final user = userSnapshot.data!;
                final userData = user.data() as Map<String, dynamic>? ?? {};

                return Column(
                  children: items.map((item) {
                    return _buildOrderCard(
                      productName: item['name'] ?? "Product",
                      quantity: item['quantity'].toString(),
                      price: item['price'].toString(),
                      imageUrl: item['imageUrl'] ?? '',
                      status: doc['status'] ?? "Pending",
                      buyerName: userData['fullName'] ?? "Buyer",
                      buyerPhone: userData['phone'] ?? "N/A",
                      buyerEmail: userData['email'] ?? "",
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

  Widget _buildOrderCard({
    required String productName,
    required String quantity,
    required String price,
    required String imageUrl,
    required String status,
    required String buyerName,
    required String buyerPhone,
    required String buyerEmail,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imageUrl.isNotEmpty
              ? Image.network(imageUrl, width: 55, height: 55, fit: BoxFit.cover)
              : Container(
            width: 55,
            height: 55,
            color: Colors.grey[300],
            child: const Icon(Icons.image_not_supported),
          ),
        ),
        title: Text(productName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Quantity: $quantity"),
            Text("Price: ₹$price"),
            const SizedBox(height: 6),
            Text("Buyer: $buyerName"),
            Text("Phone: $buyerPhone"),
            Text("Email: $buyerEmail"),
            const SizedBox(height: 6),
            Text(
              "Status: $status",
              style: TextStyle(fontWeight: FontWeight.bold, color: _getStatusColor(status)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.inbox, size: 80, color: Colors.grey),
          SizedBox(height: 10),
          Text("No orders found", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(child: Text(message, style: const TextStyle(color: Colors.red)));
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "pending":
        return Colors.orange;
      case "delivered":
        return Colors.green;
      case "cancelled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
