import 'package:agrivision/screens/trader/trader_add_product_screen.dart';
import 'package:agrivision/screens/trader/trader_climate_guidencess_screen.dart';
import 'package:agrivision/screens/trader/trader_contact_us_screen.dart';
import 'package:agrivision/screens/trader/trader_edit_product_screen.dart';
import 'package:agrivision/screens/trader/trader_notification_screen.dart';
import 'package:agrivision/screens/trader/trader_order_screen.dart';
import 'package:agrivision/screens/trader/trader_payment_screen.dart';
import 'package:agrivision/screens/trader/trader_profile_page.dart';
import 'package:agrivision/screens/trader/trader_service_screen.dart';
import 'package:flutter/material.dart';
import '../../utiles/routes/routes_name.dart';
import 'home_page.dart';

class TraderHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trader Dashboard"),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => TraderProfilePage()),
                          );
                        },
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: AssetImage('assets/profile_picture.jpg'), // Replace with your profile image asset
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.notifications, color: Colors.white),
                        onPressed: () {

                          Navigator.push(context, MaterialPageRoute(builder: (context) => TraderNotificationScreen()));

                          // Handle notification icon press
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'User Name', // Replace with the actual user name
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  )
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.build),
              title: Text('Service'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => TraderServiceScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.cloud),
              title: Text('Climate Guideness'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => TraderClimateGuidencessScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart),
              title: Text('Order'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => TraderOrderScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.payment),
              title: Text('Payment'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => TraderPaymentScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Add Product'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => TraderAddProductScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.update),
              title: Text('Edit Product'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => TraderEditProductScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.contact_mail),
              title: Text('Contact Us'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => TraderContactUsScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(
                      context, RoutesName.loginScreen, (route) => false);

              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text("Welcome, Trader!", style: TextStyle(fontSize: 22)),
      ),
    );
  }
}