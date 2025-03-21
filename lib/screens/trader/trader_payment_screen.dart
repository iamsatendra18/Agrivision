import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart'; // For date formatting

class TraderPaymentScreen extends StatelessWidget {
  final List<Map<String, dynamic>> payments = [
    {
      "product": "🌾 Wheat",
      "amount": "₹5,000",
      "transactionId": "TXN123456",
      "date": "2025-03-15",
      "paymentMethod": "Cash",
      "status": "Completed",
      "icon": LucideIcons.wheat,
    },
    {
      "product": "🍏 Apples",
      "amount": "₹3,200",
      "transactionId": "TXN654321",
      "date": "2025-03-14",
      "paymentMethod": "Bank Transfer",
      "status": "Pending",
      "icon": LucideIcons.apple,
    },
    {
      "product": "🥛 Dairy Milk",
      "amount": "₹6,800",
      "transactionId": "TXN789654",
      "date": "2025-03-10",
      "paymentMethod": "Cash",
      "status": "Completed",
      "icon": LucideIcons.milk,
    },
    {
      "product": "🥦 Spinach",
      "amount": "₹1,500",
      "transactionId": "TXN112233",
      "date": "2025-03-09",
      "paymentMethod": "FonePay",
      "status": "Failed",
      "icon": LucideIcons.leaf,
    },
    {
      "product": "🥕 Carrots",
      "amount": "₹2,400",
      "transactionId": "TXN556677",
      "date": "2025-02-25",
      "paymentMethod": "Credit Card",
      "status": "Completed",
      "icon": LucideIcons.carrot,
    },
  ];

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredPayments = _filterLast30DaysPayments();

    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: Text(
          'Payment History (Last 30 Days)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[700],
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft), // Back button
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
      ),
      body: filteredPayments.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: filteredPayments.length,
        itemBuilder: (context, index) {
          return _buildPaymentCard(filteredPayments[index]);
        },
      ),
    );
  }

  /// UI when there are no payments
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

  /// Payment Card Widget
  Widget _buildPaymentCard(Map<String, dynamic> payment) {
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
              "Date: ${_formatDate(payment["date"])}",
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

  /// Function to determine payment status color
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

  /// Function to filter payments from the last 30 days
  List<Map<String, dynamic>> _filterLast30DaysPayments() {
    DateTime today = DateTime.now();
    DateTime last30Days = today.subtract(Duration(days: 30));

    return payments.where((payment) {
      try {
        DateTime paymentDate = DateTime.parse(payment["date"]);
        return paymentDate.isAfter(last30Days) && paymentDate.isBefore(today);
      } catch (e) {
        print("Error parsing date: ${payment["date"]} - $e");
        return false;
      }
    }).toList();
  }

  /// Function to format date as "March 15, 2025"
  String _formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat("MMMM d, yyyy").format(parsedDate);
    } catch (e) {
      print("Error formatting date: $date - $e");
      return date; // Return original string if formatting fails
    }
  }
}
