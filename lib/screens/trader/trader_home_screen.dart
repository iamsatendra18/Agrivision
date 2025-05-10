import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:agrivision/screens/trader/trader_add_product_screen.dart';
import 'package:agrivision/screens/trader/trader_anudan_screen.dart';
import 'package:agrivision/screens/trader/trader_climate_guidencess_screen.dart';
import 'package:agrivision/screens/trader/trader_contact_us_screen.dart';
import 'package:agrivision/screens/trader/trader_edit_product_screen.dart';
import 'package:agrivision/screens/trader/trader_notification_screen.dart';
import 'package:agrivision/screens/trader/trader_order_screen.dart';
import 'package:agrivision/screens/trader/trader_payment_screen.dart';
import 'package:agrivision/screens/trader/trader_privacy_policy_screen.dart';
import 'package:agrivision/screens/trader/trader_product_list_screen.dart';
import 'package:agrivision/screens/trader/trader_profile_page.dart';
import 'package:agrivision/screens/trader/trader_terms_and_conditions_screen.dart';
import 'package:agrivision/utiles/routes/routes_name.dart';

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
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final screenWidth = constraints.maxWidth;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => TraderProfilePage()));
                                },
                                child: CircleAvatar(
                                  radius: screenWidth < 400 ? 30 : 40,
                                  backgroundImage: imageUrl.isNotEmpty
                                      ? (imageUrl.startsWith('assets/')
                                      ? AssetImage(imageUrl) as ImageProvider
                                      : NetworkImage(imageUrl))
                                      : const AssetImage('assets/profile_picture.jpg'),
                                ),
                              ),
                              const Spacer(),
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('notifications')
                                    .where('to', isEqualTo: 'trader')
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  final count = snapshot.data?.docs.length ?? 0;
                                  return Stack(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.notifications, color: Colors.white),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (_) => TraderNotificationScreen()),
                                          );
                                        },
                                      ),
                                      if (count > 0)
                                        Positioned(
                                          right: 6,
                                          top: 6,
                                          child: Container(
                                            padding: const EdgeInsets.all(5),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                                            child: Text(
                                              '$count',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            traderName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth < 400 ? 18 : 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),

            // Drawer List Items
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
              leading: Icon(Icons.privacy_tip),
              title: Text('Privacy Policy'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TraderPrivacyPolicyScreen())),
            ),
            ListTile(
              leading: Icon(Icons.article),
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
