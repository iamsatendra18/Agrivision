import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminContactMessagesTab extends StatefulWidget {
  @override
  State<AdminContactMessagesTab> createState() => _AdminContactMessagesTabState();
}

class _AdminContactMessagesTabState extends State<AdminContactMessagesTab> {
  String filterRole = 'All'; // All, User, Trader

  Future<Map<String, String>> _getSenderDetails(String userId) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists && userDoc.data()?['fullName'] != null) {
      return {'name': userDoc.data()!['fullName'], 'role': 'User'};
    }

    final traderDoc = await FirebaseFirestore.instance.collection('traders').doc(userId).get();
    if (traderDoc.exists && traderDoc.data()?['fullName'] != null) {
      return {'name': traderDoc.data()!['fullName'], 'role': 'Trader'};
    }

    return {'name': 'Unknown', 'role': 'Unknown'};
  }

  void _deleteMessage(BuildContext context, String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete Message'),
        content: Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('contact_messages').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Message deleted')),
      );
    }
  }

  void _replyToMessage(BuildContext context, String userId) async {
    final TextEditingController _replyController = TextEditingController();

    final shouldSend = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Reply to Message'),
        content: TextFormField(
          controller: _replyController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Enter your reply message...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Send Reply'),
          ),
        ],
      ),
    );

    if (shouldSend == true && _replyController.text.trim().isNotEmpty) {
      await FirebaseFirestore.instance.collection('admin_replies').add({
        'userId': userId,
        'message': _replyController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reply sent')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Messages"),
        backgroundColor: Color(0xFF2E7D32),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => setState(() => filterRole = value),
            itemBuilder: (_) => [
              PopupMenuItem(value: 'All', child: Text('Show All')),
              PopupMenuItem(value: 'User', child: Text('Only Users')),
              PopupMenuItem(value: 'Trader', child: Text('Only Traders')),
            ],
            icon: Icon(Icons.filter_list),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('contact_messages')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return Center(child: Text("No messages available."));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final timestamp = data['timestamp'] != null
                  ? (data['timestamp'] as Timestamp).toDate()
                  : null;
              final formattedTime = timestamp != null
                  ? "${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}"
                  : '';
              final userId = data['userId'] ?? '';

              return FutureBuilder<Map<String, String>>(
                future: _getSenderDetails(userId),
                builder: (context, snapshot) {
                  final name = snapshot.data?['name'] ?? 'Loading...';
                  final role = snapshot.data?['role'] ?? '';

                  if (filterRole != 'All' && filterRole != role) return SizedBox();

                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(0xFF2E7D32),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Row(
                        children: [
                          Expanded(child: Text(name, style: TextStyle(fontWeight: FontWeight.bold))),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: role == 'Trader' ? Colors.orange.shade100 : Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              role,
                              style: TextStyle(
                                color: role == 'Trader' ? Colors.orange.shade800 : Colors.blue.shade800,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data['message'] ?? ''),
                          SizedBox(height: 4),
                          Text(formattedTime, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.reply, color: Colors.green),
                            onPressed: () => _replyToMessage(context, userId),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteMessage(context, doc.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
