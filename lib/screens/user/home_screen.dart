import 'package:agrivision/screens/auth/login_screen.dart';
import 'package:agrivision/utiles/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  final List<Map<String, String>> items = [
    {'name': 'Apple', 'image': 'assets/apple.jpg', 'price' : '100', 'quantity' : '10'},
    {'name': 'Banana', 'image': 'assets/banana.jpg', 'price' : '200', 'quantity' : '20'},
    {'name': 'Carrot', 'image': 'assets/carrot.jpg', 'price' : '300', 'quantity' : '30'},
    {'name': 'Tomato', 'image': 'assets/tomato.jpg', 'price' : '400', 'quantity' : '40'},
    {'name': 'Potato', 'image': 'assets/potato.jpg', 'price' : '500', 'quantity' : '50'},
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>(); // Efficient provider use
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            // Fixed SliverAppBar
            SliverAppBar(
              backgroundColor: Colors.green[500],
              floating: true,
              snap: true,
              title: Builder(
                builder: (context) {
                  return Row(
                    children: [
                      Image.asset(
                        'assets/agrivision_logo.png',
                        height: screenHeight * 0.1, // Responsive logo size
                      ),
                      SizedBox(width: screenWidth * 0.04),
                      Text('Hi! Satendra',),
                      SizedBox(width: screenWidth * 0.15),
                      Icon(Icons.notification_important_outlined),
                      // SizedBox(width: screenWidth * 0.03),
                      // Spacer(),
                      TextButton(onPressed: () {
                        Navigator.pushNamed(context, RoutesName.cartBasketScreen);
                      },
                      child: Icon(Icons.add_shopping_cart_outlined)),
                      // SizedBox(width: screenWidth * 0.03),

                    ],
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: screenHeight * 0.01,),
            ),
            SliverToBoxAdapter(
              child: SearchFieldWidget(),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: screenHeight * 0.01,),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
              sliver: SliverToBoxAdapter(
                child: Text('Trending Products', style: TextStyle(fontSize: screenWidth * 0.06, fontWeight: FontWeight.bold)),
              ),
            ),
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: items.map((item) {
                    return Container(
                      width: screenWidth * 0.4, // Adjust the width as needed
                      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                      child: TextButton(
                        onPressed: () { Navigator.pushNamed(
                          context,
                          RoutesName.productDetailScreen,
                          arguments: {
                            'productName': item['name'],
                            'productImage': item['image'],
                            'productDescription': 'This is a description of ${item['name']}',
                            'productPrice': double.parse(item['price']!),
                            'productQuantity': double.parse(item['quantity']!),
                          },
                        ); },
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(screenWidth * 0.05),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                item['image']!,
                                height: screenHeight * 0.10,
                              ),
                              // SizedBox(height: screenHeight * 0.02),
                              Text(
                                item['name']!,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.05,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Rs. ',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.05,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  Text(
                                    item['price']!,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.05,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'KG: ',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.05,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  Text(
                                    item['quantity']!,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.05,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              ElevatedButton(
                                onPressed: () {},
                                child: Text("Buy Now"),
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
            SliverToBoxAdapter(
              child: SizedBox(height: screenHeight * 0.01,),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
              sliver: SliverToBoxAdapter(
                child: Text('Features Products', style: TextStyle(fontSize: screenWidth * 0.06, fontWeight: FontWeight.bold)),
              ),
            ),
            // Grid Items
            Builder(
              builder: (context) {
                return SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      return TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, RoutesName.productDetailScreen, arguments: {
                            'productName': items[index]['name'],
                            'productImage': items[index]['image'],
                            'productDescription': 'This is a description of ${items[index]['name']}',
                            'productPrice': double.parse(items[index]['price']!),
                            'productQuantity': double.parse(items[index]['quantity']!),
                          });
                        },
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(screenWidth * 0.05),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                items[index]['image']!,
                                height: screenHeight * 0.10,
                              ),
                              // SizedBox(height: screenHeight * 0.02),
                              Text(
                                items[index]['name']!,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.05,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Rs. ',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.05,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  Text(
                                    items[index]['price']!,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.05,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'KG: ',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.05,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  Text(
                                    items[index]['quantity']!,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.05,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              ElevatedButton(
                                onPressed: () {},
                                child: Text("Buy Now"),
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Extracted SearchField Widget to avoid GlobalKey errors
class SearchFieldWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search...',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.black12,
      ),
    );
  }
}
