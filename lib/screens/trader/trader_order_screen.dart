import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TraderOrderScreen extends StatefulWidget {
  const TraderOrderScreen({super.key});

  @override
  State<TraderOrderScreen> createState() => _TraderOrderScreenState();
}

class _TraderOrderScreenState extends State<TraderOrderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _statuses = ["All", "Pending", "Delivered", "Cancelled"];
  String? traderId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statuses.length, vsync: this);
    traderId = FirebaseAuth.instance.currentUser?.uid;
  }

  void _updateOrderStatus(String orderId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({'status': newStatus});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(" Order marked as $newStatus")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(" Failed to update status: $e")),
      );
    }
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
          ? const Center(child: Text(" Trader not logged in"))
          : TabBarView(
        controller: _tabController,
        children:
        _statuses.map((status) => _buildOrderList(status)).toList(),
      ),
    );
  }

  Widget _buildOrderList(String statusFilter) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .orderBy('orderedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final traderOrders = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final items = data['items'] as List<dynamic>? ?? [];
          final status = (data['status'] ?? "").toString().toLowerCase();
          final matchesStatus =
              statusFilter == "All" || status == statusFilter.toLowerCase();
          final containsTraderItem =
          items.any((item) => item['traderId'] == traderId);
          return containsTraderItem && matchesStatus;
        }).toList();

        if (traderOrders.isEmpty) {
          return const Center(child: Text(" No orders found for your products."));
        }

        return ListView.builder(
          itemCount: traderOrders.length,
          itemBuilder: (context, index) {
            final doc = traderOrders[index];
            final data = doc.data() as Map<String, dynamic>;
            final userId = data['userId'];
            final status = data['status'] ?? 'Pending';
            final filteredItems = (data['items'] as List<dynamic>)
                .where((item) => item['traderId'] == traderId)
                .toList();

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
              builder: (context, userSnap) {
                if (!userSnap.hasData) return const SizedBox();

                final userData = userSnap.data?.data() as Map<String, dynamic>? ?? {};
                final buyerName = userData['fullName'] ?? 'Unknown';
                final buyerImage = userData['imageUrl'] ?? '';
                final buyerPhone = userData['phone'] ?? '';
                final buyerAddress = userData['address'] ?? '';

                return Column(
                  children: filteredItems.map((item) {
                    final productName = item['name'] ?? 'Unnamed';
                    final qty = item['quantity'];
                    final price = item['price'];

                    return FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('products')
                          .where('name', isEqualTo: productName)
                          .get(),
                      builder: (context, prodSnap) {
                        final prodDoc = prodSnap.data?.docs.firstOrNull;
                        final prodImage = prodDoc?.get('imageUrl') ?? '';

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: ClipOval(
                                    child: buyerImage.startsWith("http")
                                        ? Image.network(buyerImage, width: 45, height: 45, fit: BoxFit.cover)
                                        : Image.asset(
                                      buyerImage.isNotEmpty
                                          ? buyerImage
                                          : "assets/agrivision_logo.png",
                                      width: 45,
                                      height: 45,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  title: Text(productName),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Qty: $qty | Price: ₹$price"),
                                      Text("Buyer: $buyerName"),
                                      Text("Phone: $buyerPhone"),
                                      Text("Address: $buyerAddress"),
                                      Text(
                                        "Status: $status",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: _getStatusColor(status),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                prodImage.isNotEmpty
                                    ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: prodImage.startsWith("http")
                                      ? Image.network(prodImage, height: 140, fit: BoxFit.cover)
                                      : Image.asset(prodImage, height: 140, fit: BoxFit.cover),
                                )
                                    : const Icon(Icons.image_not_supported),
                                const SizedBox(height: 10),
                                if (status == 'Pending')
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () => _updateOrderStatus(doc.id, 'Delivered'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green[700],
                                        ),
                                        child: const Text("Confirm"),
                                      ),
                                      const SizedBox(width: 8),
                                      OutlinedButton(
                                        onPressed: () => _updateOrderStatus(doc.id, 'Cancelled'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.red,
                                          side: const BorderSide(color: Colors.red),
                                        ),
                                        child: const Text("Cancel"),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
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
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}