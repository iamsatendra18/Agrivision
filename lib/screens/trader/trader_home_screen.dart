import 'package:agrivision/screens/trader/trader_add_product_screen.dart';
import 'package:agrivision/screens/trader/trader_climate_guidencess_screen.dart';
import 'package:agrivision/screens/trader/trader_contact_us_screen.dart';
import 'package:agrivision/screens/trader/trader_edit_product_screen.dart';
import 'package:agrivision/screens/trader/trader_notification_screen.dart';
import 'package:agrivision/screens/trader/trader_order_screen.dart';
import 'package:agrivision/screens/trader/trader_payment_screen.dart';
import 'package:agrivision/screens/trader/trader_privacy_policy_screen.dart';
import 'package:agrivision/screens/trader/trader_product_list_screen.dart';
import 'package:agrivision/screens/trader/trader_profile_page.dart';
import 'package:agrivision/screens/trader/trader_anudan_screen.dart';
import 'package:agrivision/screens/trader/trader_terms_and_conditions_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../utiles/routes/routes_name.dart';

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
                String imageUrl = '';

                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  traderName = data['fullName'] ?? 'Trader';
                  imageUrl = data['imageUrl'] ?? '';
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
                              backgroundImage: imageUrl.isNotEmpty
                                  ? imageUrl.startsWith('assets/')
                                  ? AssetImage(imageUrl) as ImageProvider
                                  : NetworkImage(imageUrl)
                                  : AssetImage('assets/profile_picture.jpg'),
                            ),
                          ),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('notifications')
                                .where('to', isEqualTo: 'trader')
                                .snapshots(),
                            builder: (context, snapshot) {
                              final count = snapshot.data?.docs.length ?? 0;
                              return Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.notifications, color: Colors.white),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => TraderNotificationScreen()),
                                      );
                                    },
                                  ),
                                  if (count > 0)
                                    Positioned(
                                      right: 6,
                                      top: 6,
                                      child: Container(
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          '$count',
                                          style: TextStyle(color: Colors.white, fontSize: 10),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          )
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
              leading: Icon(Icons.volunteer_activism),
              title: Text('Anudan'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TraderAnudanScreen())),
            ),
            ListTile(
              leading: Icon(Icons.agriculture),
              title: Text('Crop Recommendation'),
              onTap: () => Navigator.pushNamed(context, RoutesName.traderCropRecommendationScreen),
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
              leading: Icon(Icons.contact_mail),
              title: Text('Privacy Policy'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TraderPrivacyPolicyScreen())),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Terms and Conditions'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TraderTermsAndConditionsScreen())),
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
