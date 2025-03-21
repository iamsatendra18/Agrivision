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

  // **Signup Function**
  Future<void> signup(
      String fullName,
      String address,
      String phone,
      String email,
      String password,
      String role, // Role: 'User' or 'Trader'
      BuildContext context) async {

    _isLoading = true;
    notifyListeners();

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password
      );

      User? user = userCredential.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'fullName': fullName,
          'address': address,
          'phone': phone,
          'email': email,
          'role': role, // Storing role in Firestore
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Signup successful!"))
        );

        // Redirect based on role
        if (role == 'Trader') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => TraderHomeScreen()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => NavigationMenu()));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Signup failed: ${e.toString()}"))
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  // **Login Function (With Fixed Role Authentication)**
  Future<void> login(String email, String password, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password
      );

      User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          String role = userDoc.get('role') ?? ''; // Retrieve role from Firestore

          // Navigate based on role
          if (role == 'Trader') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => TraderHomeScreen()),
            );
          } else if (role == 'User') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => NavigationMenu()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Invalid role assigned. Contact support."))
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("User data not found. Please try again."))
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An error occurred: ${e.toString()}"))
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  // **Logout Function**
  void logout() {
    _auth.signOut();
  }
}
