import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminContactMessagesTab extends StatefulWidget {
  @override
  State<AdminContactMessagesTab> createState() => _AdminContactMessagesTabState();
}

class _AdminContactMessagesTabState extends State<AdminContactMessagesTab> {
  String filterRole = 'All';

  Future<void> _replyToMessage(BuildContext context, String userId) async {
    final controller = TextEditingController();
    String? docId;

    final replySnap = await FirebaseFirestore.instance
        .collection('admin_replies')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (replySnap.docs.isNotEmpty) {
      controller.text = replySnap.docs.first['message'] ?? '';
      docId = replySnap.docs.first.id;
    }

    final send = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(docId != null ? 'Edit Reply' : 'Reply to Message'),
        content: TextFormField(
          controller: controller,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Enter your reply...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(docId != null ? 'Update' : 'Send'),
          ),
        ],
      ),
    );

    if (send == true && controller.text.trim().isNotEmpty) {
      final replyData = {
        'userId': userId,
        'message': controller.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      };

      if (docId != null) {
        await FirebaseFirestore.instance.collection('admin_replies').doc(docId).update(replyData);
      } else {
        await FirebaseFirestore.instance.collection('admin_replies').add(replyData);
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reply saved')));
      setState(() {}); // refresh UI
    }
  }

  Future<void> _deleteMessage(BuildContext context, String docId) async {
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Message deleted')));
    }
  }

  Future<List<Map<String, dynamic>>> _getReplies(String userId) async {
    final snap = await FirebaseFirestore.instance
        .collection('admin_replies')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();
    return snap.docs.map((e) => e.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3FCE7),
      appBar: AppBar(
        title: Text("User Messages"),
        backgroundColor: Color(0xFF2E7D32),
        actions: [
          PopupMenuButton<String>(
            onSelected: (val) => setState(() => filterRole = val),
            itemBuilder: (_) => [
              PopupMenuItem(value: 'All', child: Text('All')),
              PopupMenuItem(value: 'User', child: Text('Users')),
              PopupMenuItem(value: 'Trader', child: Text('Traders')),
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
        builder: (ctx, snap) {
          if (!snap.hasData) return Center(child: CircularProgressIndicator());

          final docs = snap.data!.docs;
          if (docs.isEmpty) return Center(child: Text('No messages'));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final name = data['name'] ?? 'Unknown';
              final role = data['role'] ?? 'Unknown';
              final userId = data['userId'] ?? '';
              final message = data['message'] ?? '';
              final time = (data['timestamp'] as Timestamp?)?.toDate();
              final date = time != null
                  ? "${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')} "
                  "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}"
                  : '';

              if (filterRole != 'All' && filterRole != role) return SizedBox();

              return FutureBuilder<List<Map<String, dynamic>>>(
                future: _getReplies(userId),
                builder: (ctx, replySnap) {
                  final replies = replySnap.data ?? [];

                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name & Role
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.green.shade700,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: role == 'Trader' ? Colors.orange.shade100 : Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  role,
                                  style: TextStyle(
                                    color: role == 'Trader' ? Colors.orange.shade800 : Colors.blue.shade800,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 10),

                          // Message
                          Text(message, style: TextStyle(fontSize: 14)),
                          SizedBox(height: 4),
                          Text(date, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                          SizedBox(height: 10),

                          // Replies
                          if (replies.isNotEmpty) ...[
                            Divider(),
                            Text("Admin Replies:", style: TextStyle(fontWeight: FontWeight.bold)),
                            ...replies.map((r) {
                              final t = (r['timestamp'] as Timestamp?)?.toDate();
                              final tStr = t != null
                                  ? "${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')} "
                                  "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}"
                                  : '';
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.subdirectory_arrow_right, size: 16, color: Colors.green),
                                    SizedBox(width: 6),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(r['message'] ?? '', style: TextStyle(fontSize: 14)),
                                          Text(tStr, style: TextStyle(fontSize: 12, color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            })
                          ],

                          SizedBox(height: 10),

                          // Action Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _replyToMessage(context, userId),
                                icon: Icon(Icons.reply, size: 18),
                                label: Text('Reply'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade600,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                ),
                              ),
                              SizedBox(width: 8),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteMessage(context, docs[i].id),
                              )
                            ],
                          )
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
