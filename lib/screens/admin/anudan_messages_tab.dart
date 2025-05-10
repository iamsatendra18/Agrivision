import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AnudanMessagesTab extends StatefulWidget {
  @override
  _AnudanMessagesTabState createState() => _AnudanMessagesTabState();
}

class _AnudanMessagesTabState extends State<AnudanMessagesTab> {
  final CollectionReference anudanRef =
  FirebaseFirestore.instance.collection('anudan_messages');

  void _deleteMessage(String docId) async {
    try {
      await anudanRef.doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Message deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting message: $e')),
      );
    }
  }

  void _editMessage(String docId, String oldTitle, String oldMessage) {
    final titleController = TextEditingController(text: oldTitle);
    final messageController = TextEditingController(text: oldMessage);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit Anudan'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: messageController,
                maxLines: 5,
                decoration: InputDecoration(labelText: 'Message'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await anudanRef.doc(docId).update({
                'title': titleController.text.trim(),
                'message': messageController.text.trim(),
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Message updated successfully')),
              );
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void _addNewMessage() {
    final titleController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Add New Anudan'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: messageController,
                maxLines: 5,
                decoration: InputDecoration(labelText: 'Message'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await anudanRef.add({
                'title': titleController.text.trim(),
                'message': messageController.text.trim(),
                'timestamp': FieldValue.serverTimestamp(),
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Anudan message added')),
              );
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text('Anudan Messages'),
        backgroundColor: Color(0xFF2E7D32),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addNewMessage,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: anudanRef.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Center(child: Text('Error loading messages'));
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No anudan messages found.'));
          }

          final messages = snapshot.data!.docs;

          return ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final doc = messages[index];
              final data = doc.data() as Map<String, dynamic>;

              final title = data['title'] ?? 'No Title';
              final message = data['message'] ?? 'No Message';
              final timestamp = data['timestamp'] != null
                  ? DateFormat('dd MMM yyyy, hh:mm a')
                  .format((data['timestamp'] as Timestamp).toDate())
                  : 'No Date';

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: isWideScreen
                        ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: Color(0xFF2E7D32),
                          child: Icon(Icons.volunteer_activism,
                              color: Colors.white),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[800])),
                              SizedBox(height: 6),
                              Text(message),
                              SizedBox(height: 6),
                              Text(timestamp,
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.orange),
                              onPressed: () =>
                                  _editMessage(doc.id, title, message),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteMessage(doc.id),
                            ),
                          ],
                        )
                      ],
                    )
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: Color(0xFF2E7D32),
                            child: Icon(Icons.volunteer_activism,
                                color: Colors.white),
                          ),
                          title: Text(title,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[800])),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 6),
                              Text(message),
                              SizedBox(height: 6),
                              Text(timestamp,
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.orange),
                                onPressed: () =>
                                    _editMessage(doc.id, title, message),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteMessage(doc.id),
                              ),
                            ],
                          ),
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
  }
}
