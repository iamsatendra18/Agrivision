import 'package:agrivision/screens/user/navigation_menu.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../screens/user/home_screen.dart';
import '../screens/trader_home_screen.dart'; // Import Trader Home Screen

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> signup(
      String fullName,
      String address,
      String phone,
      String email,
      String password,
      String role, // Added role parameter
      BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = userCredential.user;

      if (user != null) {
        await saveUserData(user.uid, fullName, address, phone, email, role); // Save role

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Signup successful!")));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Signup failed: ${e.toString()}")));
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveUserData(
      String userId, String fullName, String address, String phone, String email, String role) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("User not authenticated");
      return;
    }

    await _firestore.collection('users').doc(user.uid).set({
      'fullName': fullName,
      'address': address,
      'phone': phone,
      'email': email,
      'role': role, // Store role in Firestore
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> login(String email, String password, String Role, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      if (user != null) {
        // Fetch user role
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        String role = userDoc['role'];

        if (role == 'Trader') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => TraderHomeScreen()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => NavigationMenu()));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login failed: ${e.toString()}")));
    }

    _isLoading = false;
    notifyListeners();
  }

  void logout() {
    _auth.signOut();
  }
}
