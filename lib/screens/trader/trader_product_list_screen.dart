import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'trader_edit_product_screen.dart';
import 'trader_home_screen.dart'; // import for navigating back

class TraderProductListScreen extends StatefulWidget {
  @override
  _TraderProductListScreenState createState() => _TraderProductListScreenState();
}

class _TraderProductListScreenState extends State<TraderProductListScreen> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  Future<void> _deleteProduct(String productId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete Product'),
        content: Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance.collection('products').doc(productId).delete();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("🗑️ Product deleted.")));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Failed to delete: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => TraderHomeScreen()),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("My Products"),
          backgroundColor: Colors.green[700],
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => TraderHomeScreen()),
              );
            },
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('products')
              .where('createdBy', isEqualTo: userId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text("No products added yet."));
            }

            final products = snapshot.data!.docs;

            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final doc = products[index];
                final data = doc.data() as Map<String, dynamic>;
                final imageUrl = data['imageUrl']?.toString() ?? '';

                ImageProvider imageProvider;
                if (imageUrl.startsWith('assets/')) {
                  imageProvider = AssetImage(imageUrl);
                } else if (imageUrl.isNotEmpty) {
                  imageProvider = NetworkImage(imageUrl);
                } else {
                  imageProvider = AssetImage('assets/agrivision_logo.png');
                }

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: imageProvider,
                      radius: 25,
                    ),
                    title: Text(data['name']),
                    subtitle: Text("₹${data['price']} • ${data['quantity']}kg"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.green),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TraderEditProductScreen(productId: doc.id),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteProduct(doc.id),
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
    );
  }
}
