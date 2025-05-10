import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TraderAnudanScreen extends StatelessWidget {
  final CollectionReference anudanRef =
  FirebaseFirestore.instance.collection('anudan_messages');

  void _showMessageDialog(BuildContext context, String title, String message, String timestamp) {
    final screenWidth = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding: EdgeInsets.symmetric(horizontal: screenWidth < 500 ? 24 : screenWidth * 0.2),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.campaign, size: 40, color: Colors.green[700]),
                  SizedBox(height: 10),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: screenWidth < 500 ? 18 : 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[900],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: screenWidth < 500 ? 15 : 17,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12),
                  Text(
                    timestamp,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
                    onPressed: () => Navigator.pop(context),
                    child: Text("Close", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        return Scaffold(
          appBar: AppBar(
            title: Text('Govt. Anudan Messages'),
            backgroundColor: Color(0xFF2E7D32),
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: anudanRef.orderBy('timestamp', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text(' Error loading messages'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: Colors.green));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('📭 No Anudan messages found.'));
              }

              final messages = snapshot.data!.docs;

              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: isWide ? 60 : 16, vertical: 10),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final data = msg.data() as Map<String, dynamic>;

                  final title = data['title'] ?? 'No Title';
                  final message = data['message'] ?? 'No Message';
                  final timestamp = data['timestamp'] != null
                      ? DateFormat('dd MMM yyyy, hh:mm a').format(
                      (data['timestamp'] as Timestamp).toDate())
                      : 'No Date';

                  return GestureDetector(
                    onTap: () => _showMessageDialog(context, title, message, timestamp),
                    child: Card(
                      elevation: 4,
                      margin: EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Icon(Icons.campaign, color: Colors.white),
                        ),
                        title: Text(title,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.green[900])),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 6),
                            Text(message),
                            SizedBox(height: 6),
                            Text(
                              timestamp,
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
