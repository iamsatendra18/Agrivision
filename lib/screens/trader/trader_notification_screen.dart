import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TraderNotificationScreen extends StatelessWidget {
  const TraderNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Trader Notifications"),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data?.data() as Map<String, dynamic>?;
          if (userData == null || !userData.containsKey('role')) {
            return const Center(child: Text(" Role not found. Please contact support."));
          }

          final String role = userData['role'].toString().toLowerCase().trim();

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('notifications')
                    .where('to', isEqualTo: role)
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("📭 No notifications available."));
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isWide ? 600 : double.infinity,
                        ),
                        child: Column(
                          children: snapshot.data!.docs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final title = data['title'] ?? 'No Title';
                            final message = data['message'] ?? '';
                            final timestamp = data['timestamp'] as Timestamp?;
                            final formattedTime = timestamp != null
                                ? DateFormat('dd MMM yyyy, hh:mm a').format(timestamp.toDate())
                                : 'No Date';

                            return GestureDetector(
                              onLongPress: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Notification'),
                                    content: const Text('Are you sure you want to delete this?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await FirebaseFirestore.instance
                                      .collection('notifications')
                                      .doc(doc.id)
                                      .delete();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("🗑️ Notification deleted")),
                                  );
                                }
                              },
                              child: Card(
                                elevation: 3,
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(message),
                                      const SizedBox(height: 6),
                                      Text(
                                        formattedTime,
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
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
