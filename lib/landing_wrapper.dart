import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'screens/user/home_screen.dart';
import 'screens/user/navigation_menu.dart';
import 'screens/trader/trader_home_screen.dart';

class LandingWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Not logged in → show HomeScreen (unauthorized)
      return HomeScreen();
    }

    // If logged in → check user role
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            body: Center(child: Text('User not found')),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final role = data['role'];

        if (role == 'Trader') {
          return TraderHomeScreen();
        } else {
          return NavigationMenu();
        }
      },
    );
  }
}
