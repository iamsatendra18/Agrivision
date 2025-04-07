import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsTab extends StatefulWidget {
  const NotificationsTab({super.key});

  @override
  State<NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<NotificationsTab> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  String selectedRole = 'trader';

  void _sendNotification(BuildContext context) async {
    String title = titleController.text.trim();
    String message = messageController.text.trim();

    if (title.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Title and message cannot be empty!")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'title': title,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'to': selectedRole,
      });

      titleController.clear();
      messageController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Sent to $selectedRole!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to send: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Push Notifications'), backgroundColor: Colors.green),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedRole,
              items: const [
                DropdownMenuItem(value: 'trader', child: Text('Trader')),
                DropdownMenuItem(value: 'user', child: Text('User')),
              ],
              onChanged: (val) => setState(() => selectedRole = val!),
              decoration: InputDecoration(labelText: 'Send To', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              maxLines: 4,
              decoration: InputDecoration(labelText: 'Message', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _sendNotification(context),
              child: const Text("Send Notification"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
