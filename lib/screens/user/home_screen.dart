import 'package:flutter/material.dart';
import 'package:agrivision/utiles/routes/routes_name.dart';

class HomeScreen extends StatelessWidget {
  final List<Map<String, String>> items = [
    {'name': 'Apple', 'image': 'assets/apple.jpg', 'price': '100', 'quantity': '10'},
    {'name': 'Banana', 'image': 'assets/banana.jpg', 'price': '200', 'quantity': '20'},
    {'name': 'Carrot', 'image': 'assets/carrot.jpg', 'price': '300', 'quantity': '30'},
    {'name': 'Tomato', 'image': 'assets/tomato.jpg', 'price': '400', 'quantity': '40'},
    {'name': 'Potato', 'image': 'assets/potato.jpg', 'price': '500', 'quantity': '50'},
  ];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFF1F8E9), // Light agriculture background
        body: CustomScrollView(
          slivers: [
            // SliverAppBar with agriculture theme
            SliverAppBar(
              backgroundColor: Color(0xFF2E7D32), // Deep Green Theme
              floating: true,
              snap: true,
              title: Row(
                children: [
                  Image.asset(
                    'assets/agrivision_logo.png',
                    height: screenHeight * 0.06, // Responsive logo size
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Text(
                    'Hi, User!',
                    style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Spacer(),
                  TextButton(
                    onPressed: (){
                      Navigator.pushNamed(context, RoutesName.userNotificationScreen);
                    },
                      child: Icon(Icons.notifications_outlined, color: Colors.white)),
                  SizedBox(width: screenWidth * 0.05),
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, RoutesName.cartBasketScreen);
                    },
                    icon: Icon(Icons.shopping_cart_outlined, color: Colors.white),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SearchFieldWidget(),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Trending Products',
                  style: TextStyle(fontSize: screenWidth * 0.06, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: items.map((item) {
                    return Container(
                      width: screenWidth * 0.45, // Adjust width
                      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.02, vertical: screenHeight * 0.02),
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                item['image']!,
                                height: screenHeight * 0.12,
                              ),
                              SizedBox(height: 10),
                              Text(
                                item['name']!,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.05,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[900],
                                ),
                              ),
                              Text(
                                'Rs. ${item['price']} / KG',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.045,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.green[700],
                                ),
                              ),
                              SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  child: Text("Buy Now"),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    backgroundColor: Color(0xFF2E7D32), // Deep Green
                                    foregroundColor: Colors.white,
                                  ),
                                ),
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
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Featured Products',
                  style: TextStyle(fontSize: screenWidth * 0.06, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                ),
              ),
            ),
            SliverGrid(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            items[index]['image']!,
                            height: screenHeight * 0.12,
                          ),
                          SizedBox(height: 10),
                          Text(
                            items[index]['name']!,
                            style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[900],
                            ),
                          ),
                          Text(
                            'Rs. ${items[index]['price']} / KG',
                            style: TextStyle(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.w500,
                              color: Colors.green[700],
                            ),
                          ),
                          SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {},
                              child: Text("Buy Now"),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: Color(0xFF2E7D32),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: items.length,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: screenWidth > 600 ? 3 : 2,
                crossAxisSpacing: screenWidth * 0.03,
                mainAxisSpacing: screenHeight * 0.02,
                childAspectRatio: 3 / 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Improved Search Field Widget
class SearchFieldWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search for products...',
        prefixIcon: Icon(Icons.search, color: Color(0xFF2E7D32)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
