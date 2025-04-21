import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/trader/trader_home_screen.dart';
import '../screens/user/navigation_menu.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // ✅ SIGNUP
  Future<void> signup(
      String fullName,
      String address,
      String phone,
      String email,
      String password,
      String role,
      BuildContext context,
      ) async {
    _isLoading = true;
    notifyListeners();

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        final userData = {
          'fullName': fullName,
          'address': address,
          'phone': phone,
          'email': email,
          'role': role.toLowerCase(), // 🔥 Store lowercase
          'createdAt': FieldValue.serverTimestamp(),
        };

        if (role.toLowerCase() == 'trader') {
          userData['verified'] = false; // 👈 initially false
        }

        await _firestore.collection('users').doc(user.uid).set(userData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Signup successful!")),
        );

        // Navigate user based on role
        if (role.toLowerCase() == 'trader') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => TraderHomeScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => NavigationMenu()),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signup failed: ${e.toString()}")),
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  // ✅ LOGIN
  Future<void> login(
      String email,
      String password,
      BuildContext context, {
        Map<String, dynamic>? redirectData,
      }) async {
    _isLoading = true;
    notifyListeners();

    try {
      UserCredential userCredential =
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          String role = (userDoc.get('role') ?? '').toString().toLowerCase(); // 🔥 force lowercase

          if (redirectData != null && redirectData['redirectTo'] != null) {
            Navigator.pushReplacementNamed(
              context,
              redirectData['redirectTo'],
              arguments: redirectData['arguments'],
            );
          } else {
            if (role == 'trader') {
              final isVerified = userDoc.data().toString().contains('verified')
                  ? userDoc['verified']
                  : false;

              if (isVerified) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => TraderHomeScreen()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Your account is not verified yet. Please wait for admin approval.",
                    ),
                  ),
                );
                await _auth.signOut(); // ❌ Logout if not verified
              }
            } else if (role == 'user') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => NavigationMenu()),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Invalid role assigned. Contact support.")),
              );
            }
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("User data not found. Please try again.")),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Login failed. Please try again.";
      if (e.code == 'user-not-found') {
        errorMessage = "No user found for this email.";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Incorrect password.";
      } else if (e.code == 'network-request-failed') {
        errorMessage = "Network error. Please check your internet connection.";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: ${e.toString()}")),
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  void logout() {
    _auth.signOut();
  }
}
