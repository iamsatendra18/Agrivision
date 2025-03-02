import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../screens/home_screen.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> signup(String fullName, String address, String phone, String email, String password, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Create user in Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      if (user != null) {
        // Save user details to Firestore
        await saveUserData(user.uid, fullName, address, phone, email);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Signup successful!")));
        Navigator.pop(context); // Navigate back to login
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Signup failed: ${e.toString()}")));
    }

    _isLoading = false;
    notifyListeners();
  }

  // Function to Save User Data in Firestore
  Future<void> saveUserData(String userId, String fullName, String address, String phone, String email) async {
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
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> login(String email, String password, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
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
