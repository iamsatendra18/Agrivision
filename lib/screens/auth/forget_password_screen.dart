import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F8E9), // Light green background
      appBar: AppBar(
        title: Text('Forgot Password'),
        centerTitle: true,
        backgroundColor: Color(0xFF2E7D32), // Dark green for agriculture theme
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.lock_reset, size: 80, color: Color(0xFF2E7D32)), // Lock Reset Icon
            SizedBox(height: 10),
            Text(
              'Reset Your Password',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
            ),
            SizedBox(height: 10),
            Text(
              'Enter your email to receive password reset instructions.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.green[700]),
            ),
            SizedBox(height: 30),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(Icons.email, color: Color(0xFF2E7D32)), // Email Icon
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Color(0xFFE8F5E9), // Soft green background for input
              ),
            ),
            SizedBox(height: 20),

            // Reset Password Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Implement password reset functionality here
                },
                icon: Icon(Icons.send, color: Colors.white), // Send Icon
                label: Text(
                  'Reset Password',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Color(0xFF2E7D32), // Dark green CTA button
                ),
              ),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Back to Login",
                style: TextStyle(color: Color(0xFF2E7D32), fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
