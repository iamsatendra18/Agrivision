import 'package:agrivision/screens/trader/trader_add_product_screen.dart';
import 'package:agrivision/screens/trader/trader_climate_guidencess_screen.dart';
import 'package:agrivision/screens/trader/trader_contact_us_screen.dart';
import 'package:agrivision/screens/trader/trader_edit_product_screen.dart';
import 'package:agrivision/screens/trader/trader_notification_screen.dart';
import 'package:agrivision/screens/trader/trader_order_screen.dart';
import 'package:agrivision/screens/trader/trader_payment_screen.dart';
import 'package:agrivision/screens/trader/trader_product_list_screen.dart';
import 'package:agrivision/screens/trader/trader_profile_page.dart';
import 'package:agrivision/screens/trader/trader_service_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../utiles/routes/routes_name.dart';
import 'home_page.dart';

class TraderHomeScreen extends StatefulWidget {
  @override
  _TraderHomeScreenState createState() => _TraderHomeScreenState();
}

class _TraderHomeScreenState extends State<TraderHomeScreen> {
  final uid = FirebaseAuth.instance.currentUser?.uid;

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
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
              builder: (context, snapshot) {
                String traderName = "Trader";
                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  traderName = data['fullName'] ?? 'Trader';
                }

                return DrawerHeader(
                  decoration: BoxDecoration(color: Colors.green),
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
                              backgroundImage: AssetImage('assets/profile_picture.jpg'),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.notifications, color: Colors.white),
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => TraderNotificationScreen()));
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          traderName,
                          style: TextStyle(color: Colors.white, fontSize: 24),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HomePage())),
            ),
            ListTile(
              leading: Icon(Icons.build),
              title: Text('Service'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TraderServiceScreen())),
            ),
            ListTile(
              leading: Icon(Icons.cloud),
              title: Text('Climate Guideness'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TraderClimateGuidencessScreen())),
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart),
              title: Text('Order'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TraderOrderScreen())),
            ),
            ListTile(
              leading: Icon(Icons.payment),
              title: Text('Payment'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TraderPaymentScreen())),
            ),
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Add Product'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TraderAddProductScreen())),
            ),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('My Products'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TraderProductListScreen())),
            ),
            ListTile(
              leading: Icon(Icons.contact_mail),
              title: Text('Contact Us'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TraderContactUsScreen())),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(context, RoutesName.loginScreen, (route) => false);
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