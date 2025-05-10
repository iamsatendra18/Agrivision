import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // For date formatting

class TraderPaymentScreen extends StatefulWidget {
  @override
  _TraderPaymentScreenState createState() => _TraderPaymentScreenState();
}

class _TraderPaymentScreenState extends State<TraderPaymentScreen> {
  final String traderId = FirebaseAuth.instance.currentUser?.uid ?? '';  // Get traderId
  List<Map<String, dynamic>> payments = [];

  @override
  void initState() {
    super.initState();
    _fetchPayments();  // Fetch payments when the screen initializes
  }

  // Fetch payments for the trader
  void _fetchPayments() async {
    if (traderId.isEmpty) {
      print("Trader ID is empty, make sure the user is logged in.");
      return;
    }

    try {
      final ordersSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('items.traderId', isEqualTo: traderId) // Filter by traderId
          .get();

      // Debugging: Check if the query returned any data
      print("Fetched orders: ${ordersSnapshot.docs.length}");

      if (ordersSnapshot.docs.isEmpty) {
        print("No orders found for this trader.");
      }

      // Process the fetched orders and store them in the payments list
      setState(() {
        payments = ordersSnapshot.docs.map((doc) {
          final data = doc.data();
          double totalAmount = 0.0;
          String paymentMethod = '';
          String status = '';

          // Calculate total for the trader's items in the order
          List items = data['items'];
          for (var item in items) {
            if (item['traderId'] == traderId) {
              totalAmount += item['total']; // Add up the total for the trader's items
            }
          }

          // Extract payment method and status from the order
          paymentMethod = data['paymentMethod'] ?? 'Unknown';
          status = data['status'] ?? 'Unknown';

          return {
            'product': 'Order ${doc.id}', // Display order ID or product name
            'amount': '₹$totalAmount', // Amount for the trader's items
            'transactionId': doc.id, // Use the order document ID as the transaction ID
            'date': DateFormat('yyyy-MM-dd').format((data['orderedAt'] as Timestamp).toDate()), // Date of the order
            'paymentMethod': paymentMethod,
            'status': status,
            'icon': LucideIcons.shoppingBag, // Icon for the payment
          };
        }).toList();
      });
    } catch (e) {
      print("Error fetching orders: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: Text(
          'Payments for Trader',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[700],
      ),
      body: payments.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: payments.length,
        itemBuilder: (context, index) {
          return _buildPaymentCard(payments[index]);
        },
      ),
    );
  }

  // UI when there are no payments
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.wallet, size: 80, color: Colors.grey[400]),
          SizedBox(height: 10),
          Text(
            "No Payment History",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600]),
          ),
          SizedBox(height: 5),
          Text(
            "Your payments will appear here once transactions are processed.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  // Payment Card Widget
  Widget _buildPaymentCard(Map<String, dynamic> payment) {
    print("Displaying Payment: ${payment['product']}, Amount: ${payment['amount']}");

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
            payment["icon"] as IconData,
            color: Colors.green[700],
            size: 30,
          ),
        ),
        title: Text(
          payment["product"] ?? '',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Amount: ${payment["amount"]}",
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
            Text(
              "Transaction ID: ${payment["transactionId"]}",
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
            Text(
              "Date: ${payment["date"]}",
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
            Text(
              "Payment Method: ${payment["paymentMethod"]}",
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
            Text(
              "Status: ${payment["status"]}",
              style: TextStyle(
                fontSize: 14,
                color: _getStatusColor(payment["status"] ?? ''),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to determine payment status color
  Color _getStatusColor(String status) {
    switch (status) {
      case "Pending":
        return Colors.orange;
      case "Completed":
        return Colors.green;
      case "Failed":
        return Colors.red;
      default:
        return Colors.black;
    }
  }
}