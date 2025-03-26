import 'package:flutter/material.dart';

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
              child: ListView.builder(
                itemCount: 10, // Replace with the actual number of payment records
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(0xFF2E7D32),
                        child: Icon(Icons.account_balance_wallet, color: Colors.white),
                      ),
                      title: Text('Trader Name $index'), // Replace with actual trader name
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Amount: \$${(index + 1) * 100}'), // Replace with actual amount
                          Text('Date: ${DateTime.now().subtract(Duration(days: index)).toLocal()}'), // Replace with actual date
                        ],
                      ),
                      trailing: Icon(Icons.arrow_forward),
                      onTap: () {
                        // Navigate to payment details screen
                      },
                    ),
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