import 'package:agrivision/screens/login_screen.dart';
import 'package:agrivision/utiles/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  final List<Map<String, String>> items = [
    {'name': 'Apple', 'image': 'assets/apple.jpg'},
    {'name': 'Banana', 'image': 'assets/banana.jpg'},
    {'name': 'Carrot', 'image': 'assets/carrot.jpg'},
    {'name': 'Tomato', 'image': 'assets/tomato.jpg'},
    {'name': 'Potato', 'image': 'assets/potato.jpg'},
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
                        height: screenHeight * 0.08, // Responsive logo size
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      Text('Hi! Satendra',),
                      SizedBox(width: screenWidth * 0.13),
                      Icon(Icons.notification_important_outlined),
                      SizedBox(width: screenWidth * 0.03),
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          authProvider.logout();
                          Navigator.pushReplacementNamed(
                            context, RoutesName.homeScreen);
                        },
                        child: CircleAvatar(
                          radius: screenHeight * 0.03,
                          backgroundImage: AssetImage('assets/apple.jpg'),
                        ),
                      ),
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
            // Grid Items
            SliverPadding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              sliver: Builder(
                builder: (context) {
                  return SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(screenWidth * 0.05),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                items[index]['image']!,
                                height: screenHeight * 0.12,
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              Text(
                                items[index]['name']!,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.05,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              ElevatedButton(
                                onPressed: () {},
                                child: Text("Buy Now"),
                              ),
                            ],
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
