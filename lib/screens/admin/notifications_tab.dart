import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminNotificationTab extends StatefulWidget {
  const AdminNotificationTab({Key? key}) : super(key: key);

  @override
  State<AdminNotificationTab> createState() => _AdminNotificationTabState();
}

class _AdminNotificationTabState extends State<AdminNotificationTab> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _selectedRole = 'user';
  bool _isSending = false;

  Future<void> _sendNotification() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'title': _titleController.text.trim(),
        'message': _messageController.text.trim(),
        'to': _selectedRole.toLowerCase(),
        'timestamp': Timestamp.now(),
      });

      _titleController.clear();
      _messageController.clear();
      setState(() => _selectedRole = 'user');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(" Notification sent successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(" Failed to send: $e")),
      );
    }

    setState(() => _isSending = false);
  }

  Future<void> _deleteNotification(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🗑️ Notification deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(' Failed to delete: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Send Notification"),
        backgroundColor: Colors.green,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isWide ? 500 : double.infinity),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                        value == null || value.trim().isEmpty ? 'Enter a title' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _messageController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Message',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                        value == null || value.trim().isEmpty ? 'Enter a message' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: const InputDecoration(
                          labelText: 'Select Role',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'user', child: Text('User')),
                          DropdownMenuItem(value: 'trader', child: Text('Trader')),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedRole = value!);
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: _isSending
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton.icon(
                          icon: const Icon(Icons.send),
                          label: const Text("Send Notification"),
                          onPressed: _sendNotification,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Sent Notifications',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('notifications')
                            .orderBy('timestamp', descending: true)
                            .limit(10)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Text("No notifications sent yet.");
                          }

                          final docs = snapshot.data!.docs;

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              final doc = docs[index];
                              final data = doc.data() as Map<String, dynamic>;
                              final title = data['title'] ?? '';
                              final message = data['message'] ?? '';
                              final role = data['to'] ?? 'user';
                              final timestamp = (data['timestamp'] as Timestamp?)?.toDate();

                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                child: ListTile(
                                  leading: const Icon(Icons.notifications, color: Colors.green),
                                  title: Text(
                                    title,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(message),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${role.toUpperCase()} • ${timestamp != null ? '${timestamp.day}/${timestamp.month}/${timestamp.year}' : 'No date'}',
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteNotification(doc.id),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
