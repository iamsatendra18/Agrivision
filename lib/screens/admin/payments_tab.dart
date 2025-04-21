import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import DateFormat

class PaymentsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment History'),
        backgroundColor: Color(0xFF2E7D32),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last 30 Days Payment History',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('payments')
                    .where('paymentDate', isGreaterThan: DateTime.now().subtract(Duration(days: 30))) // Filter for last 30 days
                    .orderBy('paymentDate', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No payment records available.'));
                  }

                  final payments = snapshot.data!.docs;
                  print('Payments: $payments'); // Debugging: Check if payments are being fetched

                  return ListView.builder(
                    itemCount: payments.length,
                    itemBuilder: (context, index) {
                      final payment = payments[index];
                      final traderName = payment['traderName'] ?? 'Unknown';
                      final amount = payment['amount'] ?? 0;
                      final paymentDate = (payment['paymentDate'] as Timestamp).toDate(); // Ensure paymentDate is a Timestamp

                      // Debug: Print paymentDate
                      print('Payment Date: $paymentDate');

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Color(0xFF2E7D32),
                            child: Icon(Icons.account_balance_wallet, color: Colors.white),
                          ),
                          title: Text(traderName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Amount: \$${amount.toStringAsFixed(2)}'),
                              Text('Date: ${DateFormat.yMMMd().add_jm().format(paymentDate)}'), // Correct date formatting
                            ],
                          ),
                          trailing: Icon(Icons.arrow_forward),
                          onTap: () {
                            // Navigate to payment details screen
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
      ),
    );
  }
}
