import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utiles/routes/routes_name.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter your email address.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password reset link sent to $email")),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "An error occurred")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F8E9),
      appBar: AppBar(
        backgroundColor: Color(0xFF2E7D32),
        title: Text("Forgot Password"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Reset Password",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Enter your registered email address and we’ll send you a link to reset your password.",
              style: TextStyle(color: Colors.green[700]),
            ),
            SizedBox(height: 24),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Email Address",
                prefixIcon: Icon(Icons.email, color: Color(0xFF2E7D32)),
                filled: true,
                fillColor: Color(0xFFE8F5E9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 24),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _resetPassword,
                child: Text("Send Reset Link"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Back to Login",
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  decoration: TextDecoration.underline,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
