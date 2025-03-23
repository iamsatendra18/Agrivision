import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:agrivision/utiles/routes/routes_name.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchText = '';
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All', 'Vegetables', 'Fruits', 'Dairy Products','Crops','Spinach', 'Grains', 'Herbs', 'Others'
  ];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFF1F8E9),
        body: Column(
          children: [
            _buildAppBar(screenHeight, screenWidth),
            _buildSearchField(),
            _buildCategoryChips(),
            Expanded(child: _buildProductGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(double screenHeight, double screenWidth) {
    return Container(
      color: Color(0xFF2E7D32),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Image.asset(
            'assets/agrivision_logo.png',
            height: screenHeight * 0.06,
          ),
          SizedBox(width: 10),
          Text(
            'Hi, User!',
            style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, RoutesName.userNotificationScreen),
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, RoutesName.cartBasketScreen),
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
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

  Widget _buildProductGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return Center(child: Text("No products found."));

        final products = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = data['name'].toString().toLowerCase();
          final category = data['category'].toString();

          final matchesSearch = _searchText.isEmpty || name.contains(_searchText);
          final matchesCategory = _selectedCategory == 'All' || category == _selectedCategory;

          return matchesSearch && matchesCategory;
        }).toList();

        return GridView.builder(
          padding: EdgeInsets.all(12),
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.7,
          ),
          itemBuilder: (context, index) {
            final doc = products[index];
            final data = doc.data() as Map<String, dynamic>;

            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  RoutesName.productDetailScreen,
                  arguments: {
                    'productId': doc.id,
                    'productName': data['name'],
                    'productImage': data['imageUrl'] ?? '',
                    'productPrice': data['price'],
                    'productQuantity': data['quantity'],
                    'productDescription': data['description'],
                  },
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                      child: data['imageUrl'] != null && data['imageUrl'].toString().isNotEmpty
                          ? Image.network(data['imageUrl'], height: 100, width: double.infinity, fit: BoxFit.cover)
                          : Image.asset('assets/agrivision_logo.png', height: 100, width: double.infinity, fit: BoxFit.cover),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Text(
                            data['name'],
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text('₹${data['price']} / ${data['quantity']}kg',
                              style: TextStyle(color: Colors.green[700])),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (i) {
                              return Icon(Icons.star, color: Colors.orange[400], size: 16);
                            }),
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
                                  'productImage': data['imageUrl'] ?? '',
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
}
