import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VerifiedProductsTab extends StatefulWidget {
  @override
  State<VerifiedProductsTab> createState() => _VerifiedProductsTabState();
}

class _VerifiedProductsTabState extends State<VerifiedProductsTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? selectedTraderId;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  Future<void> _deleteProduct(String docId, BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('products').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('🗑️ Product Deleted'), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(' Failed to delete: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildProductList(bool isVerified) {
    Query query = FirebaseFirestore.instance
        .collection('products')
        .where('isVerified', isEqualTo: isVerified);

    if (selectedTraderId != null && selectedTraderId != 'ALL') {
      query = query.where('createdBy', isEqualTo: selectedTraderId);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator());
        if (snapshot.hasError)
          return Center(child: Text(' Error loading products'));

        final products = snapshot.data?.docs ?? [];

        if (products.isEmpty) {
          return Center(
            child: Text(
              isVerified ? " No verified products available." : " No products pending verification.",
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final doc = products[index];
            final data = doc.data() as Map<String, dynamic>;

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(data['createdBy']).get(),
              builder: (context, traderSnapshot) {
                String traderInfo = "👤 Unknown Trader";
                if (traderSnapshot.hasData && traderSnapshot.data!.exists) {
                  final trader = traderSnapshot.data!.data() as Map<String, dynamic>;
                  final role = trader['role']?.toString().toLowerCase();
                  if (role == 'trader') {
                    traderInfo = '''
👤 ${trader['fullName'] ?? 'N/A'}
📞 ${trader['phone'] ?? 'N/A'}
🏠 ${trader['address'] ?? 'N/A'}''';
                  } else {
                    return SizedBox();
                  }
                }

                final imageUrl = data['imageUrl']?.toString() ?? '';

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: imageUrl.startsWith('assets/')
                              ? Image.asset(
                            imageUrl,
                            height: 80,
                            width: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 80,
                              width: 80,
                              color: Colors.grey[300],
                              child: Icon(Icons.broken_image),
                            ),
                          )
                              : Image.network(
                            imageUrl,
                            height: 80,
                            width: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 80,
                              width: 80,
                              color: Colors.grey[300],
                              child: Icon(Icons.broken_image),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data['name'] ?? 'Unnamed Product', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text(data['description'] ?? '', style: TextStyle(color: Colors.grey[700]), maxLines: 2, overflow: TextOverflow.ellipsis),
                              SizedBox(height: 4),
                              Text('₹${data['price']} • ${data['quantity']}kg', style: TextStyle(color: Colors.green[700])),
                              Divider(),
                              Text(traderInfo, style: TextStyle(fontSize: 13, color: Colors.black87)),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            if (!isVerified)
                              IconButton(
                                icon: Icon(Icons.check_circle, color: Colors.green),
                                onPressed: () async {
                                  try {
                                    await FirebaseFirestore.instance.collection('products').doc(doc.id).update({'isVerified': true});
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(' Product Verified'), backgroundColor: Colors.green),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
                                    );
                                  }
                                },
                              ),
                            IconButton(
                              icon: Icon(Icons.delete_forever, color: Colors.redAccent),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text("Delete Product"),
                                    content: Text("Are you sure you want to delete this product?"),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text("Cancel")),
                                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text("Delete")),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  _deleteProduct(doc.id, context);
                                }
                              },
                            ),
                          ],
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
    );
  }

  Widget _buildTraderDropdown() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox();

        final traders = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['role']?.toString().toLowerCase() == 'trader';
        }).toList();

        return DropdownButtonFormField<String>(
          isExpanded: true,
          value: selectedTraderId ?? 'ALL',
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
          ),
          items: [
            DropdownMenuItem(value: 'ALL', child: Text("📦 All Traders")),
            ...traders.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final name = data['fullName']?.toString().trim();
              return DropdownMenuItem(
                value: doc.id,
                child: Text(name != null && name.isNotEmpty ? name : '👤 ${doc.id.substring(0, 6)}'),
              );
            }).toList(),
          ],
          onChanged: (value) {
            setState(() {
              selectedTraderId = value == 'ALL' ? null : value;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Product Verification'),
          backgroundColor: Color(0xFF2E7D32),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(100),
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  tabs: [
                    Tab(text: 'Pending'),
                    Tab(text: 'Verified'),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _buildTraderDropdown(),
                )
              ],
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildProductList(false),
            _buildProductList(true),
          ],
        ),
      ),
    );
  }
}
