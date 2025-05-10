import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agrivision/utiles/routes/routes_name.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchText = '';
  String _selectedCategory = 'All';
  String _username = 'User';

  final List<String> _categories = [
    'All', 'Vegetables', 'Fruits', 'Dairy Products', 'Crops',
    'Spinach', 'Grains', 'Herbs', 'Others'
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();
      if (data != null && data['fullName'] != null) {
        setState(() => _username = data['fullName']);
      }
    }
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  void _launchEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (!await launchUrl(uri)) {
      throw 'Could not launch email';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFF1F8E9),
        drawer: _buildDrawer(context),
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              return Column(
                children: [
                  _buildAppBar(context),
                  _buildSearchField(),
                  _buildCategoryChips(),
                  Expanded(child: _buildProductGrid(crossAxisCount: 2)),
                ],
              );
            } else {
              return Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _buildAppBar(context),
                        _buildSearchField(),
                        _buildCategoryChips(),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: _buildProductGrid(crossAxisCount: 4),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: Color(0xFF2E7D32),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          Text(
            'Hi, $_username!',
            style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Spacer(),
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications, color: Colors.white),
                onPressed: () => Navigator.pushNamed(context, RoutesName.userNotificationScreen),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('notifications')
                    .where('to', isEqualTo: 'user')
                    .snapshots(),
                builder: (context, snapshot) {
                  final count = snapshot.data?.docs.length ?? 0;
                  if (count == 0) return SizedBox();
                  return Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: Text('$count', style: TextStyle(color: Colors.white, fontSize: 13)),
                    ),
                  );
                },
              ),
            ],
          ),
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart, color: Colors.white),
                onPressed: () {
                  if (FirebaseAuth.instance.currentUser == null) {
                    Navigator.pushNamed(context, RoutesName.loginScreen);
                  } else {
                    Navigator.pushNamed(context, RoutesName.cartBasketScreen);
                  }
                },
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseAuth.instance.currentUser != null
                    ? FirebaseFirestore.instance
                    .collection('cart')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('items')
                    .snapshots()
                    : null,
                builder: (context, snapshot) {
                  final count = snapshot.data?.docs.length ?? 0;
                  if (count == 0) return SizedBox();
                  return Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: Text('$count', style: TextStyle(fontSize: 12, color: Colors.white)),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: EdgeInsets.all(12),
      child: TextField(
        onChanged: (val) => setState(() => _searchText = val.toLowerCase()),
        decoration: InputDecoration(
          hintText: 'Search products...',
          prefixIcon: Icon(Icons.search, color: Colors.green),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Container(
      height: 40,
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (_, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              selectedColor: Colors.green[300],
              onSelected: (_) => setState(() => _selectedCategory = category),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid({required int crossAxisCount}) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('products')
          .where('isVerified', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator());

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
          return Center(child: Text("No products found."));

        final products = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = (data['name'] ?? '').toString().toLowerCase();
          final category = (data['category'] ?? '').toString().trim().toLowerCase();
          final selectedCategory = _selectedCategory.trim().toLowerCase();

          final matchesSearch = _searchText.isEmpty || name.contains(_searchText);
          final matchesCategory = selectedCategory == 'all' || category == selectedCategory;

          return matchesSearch && matchesCategory;
        }).toList();

        return GridView.builder(
          padding: EdgeInsets.all(12),
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.7,
          ),
          itemBuilder: (context, index) {
            final doc = products[index];
            final data = doc.data() as Map<String, dynamic>;
            final imageUrl = data['imageUrl']?.toString() ?? '';

            return GestureDetector(
              onTap: () => Navigator.pushNamed(
                context,
                RoutesName.productDetailScreen,
                arguments: {
                  'productId': doc.id,
                  'productName': data['name'],
                  'productImage': imageUrl,
                  'productPrice': data['price'],
                  'productQuantity': data['quantity'],
                  'productDescription': data['description'],
                },
              ),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                      child: imageUrl.startsWith('assets/')
                          ? Image.asset(imageUrl, height: 100, width: double.infinity, fit: BoxFit.cover)
                          : Image.network(
                        imageUrl,
                        height: 100,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset('assets/agrivision_logo.png', height: 100, fit: BoxFit.cover);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Text(data['name'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('₹${data['price']} / ${data['quantity']}kg', style: TextStyle(color: Colors.green[700])),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (i) => Icon(Icons.star, size: 16, color: Colors.orange[400])),
                          ),
                          SizedBox(height: 6),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                RoutesName.productDetailScreen,
                                arguments: {
                                  'productId': doc.id,
                                  'productName': data['name'],
                                  'productImage': imageUrl,
                                  'productPrice': data['price'],
                                  'productQuantity': data['quantity'],
                                  'productDescription': data['description'],
                                },
                              );
                            },
                            child: Text("Buy Now"),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 35),
                              backgroundColor: Color(0xFF2E7D32),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF2E7D32)),
            child: Center(
              child: Image.asset('assets/agrivision_logo.png', height: 75),
            ),
          ),
          ListTile(
            leading: Icon(Icons.share, color: Colors.green),
            title: Text('Share Agrivision'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.privacy_tip, color: Colors.green),
            title: Text('Privacy Policy'),
            onTap: () => Navigator.pushNamed(context, RoutesName.privacyPolicyScreen),
          ),
          ListTile(
            leading: Icon(Icons.rule, color: Colors.green),
            title: Text('Terms and Conditions'),
            onTap: () => Navigator.pushNamed(context, RoutesName.termsAndConditionsScreen),
          ),
          ListTile(
            leading: Icon(Icons.contact_page, color: Colors.green),
            title: Text('Contact Us'),
            onTap: () => Navigator.pushNamed(context, RoutesName.contactUsScreen),
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Logout'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(context, RoutesName.loginScreen, (route) => false);
            },
          ),
        ],
      ),
    );
  }
}


