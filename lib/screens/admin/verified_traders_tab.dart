import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VerifiedTradersTab extends StatefulWidget {
  @override
  _VerifiedTradersTabState createState() => _VerifiedTradersTabState();
}

class _VerifiedTradersTabState extends State<VerifiedTradersTab> {
  final CollectionReference usersRef = FirebaseFirestore.instance.collection('users');
  String searchQuery = "";
  bool showVerified = false;

  @override
  void initState() {
    super.initState();
    print('Logged-in Admin UID: ${FirebaseAuth.instance.currentUser?.uid}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify Traders'),
        backgroundColor: Color(0xFF2E7D32),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name or email',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          ToggleButtons(
            isSelected: [!showVerified, showVerified],
            onPressed: (index) {
              setState(() {
                showVerified = index == 1;
              });
            },
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('Unverified'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('Verified'),
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: usersRef
                  .where('role', isEqualTo: 'Trader')
                  .where('verified', isEqualTo: showVerified)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return Center(child: Text('Error loading traders'));
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());

                final traders = snapshot.data!.docs.where((doc) {
                  final name = (doc['fullName'] ?? '').toString().toLowerCase();
                  final email = (doc['email'] ?? '').toString().toLowerCase();
                  return name.contains(searchQuery) || email.contains(searchQuery);
                }).toList();

                if (traders.isEmpty) {
                  return Center(child: Text('No traders found.'));
                }

                return ListView.builder(
                  itemCount: traders.length,
                  itemBuilder: (context, index) {
                    final trader = traders[index];
                    final name = trader['fullName'] ?? 'Unnamed';
                    final email = trader['email'] ?? '';
                    final isVerified = trader['verified'] == true;

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color(0xFF2E7D32),
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(name),
                        subtitle: Text(email),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isVerified)
                              ElevatedButton(
                                onPressed: () async {
                                  try {
                                    await usersRef.doc(trader.id).update({'verified': true});
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('$name has been approved.')),
                                    );
                                    setState(() {});
                                  } catch (e) {
                                    print('🔥 Error approving trader: ${e.toString()}');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: ${e.toString()}')),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                child: Text('Approve'),
                              )
                            else
                              IconButton(
                                icon: Icon(Icons.close, color: Colors.red),
                                onPressed: () async {
                                  try {
                                    await usersRef.doc(trader.id).update({'verified': false});
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('$name has been unverified.')),
                                    );
                                    setState(() {});
                                  } catch (e) {
                                    print('🔥 Error unapproving trader: ${e.toString()}');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: ${e.toString()}')),
                                    );
                                  }
                                },
                              ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.grey[700]),
                              onPressed: () {
                                _showDeleteDialog(context, trader.id, name);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String traderId, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Trader'),
        content: Text('Are you sure you want to delete $name?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await usersRef.doc(traderId).delete();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$name has been deleted.')),
              );
              setState(() {});
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
