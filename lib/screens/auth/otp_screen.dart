import 'package:flutter/material.dart';
import 'package:agrivision/services/email_otp_service.dart';
import '../../utiles/routes/routes_name.dart';

class OTPScreen extends StatefulWidget {
  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  String? _generatedOtp;
  bool _otpSent = false;
  bool _isLoading = false;

  Future<void> sendOTP() async {
    setState(() => _isLoading = true);
    final otp = EmailOTPService.generateOtp();
    final success = await EmailOTPService.sendOtpEmail(emailController.text.trim(), otp);

    setState(() {
      _isLoading = false;
      if (success) {
        _otpSent = true;
        _generatedOtp = otp;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("OTP sent successfully!")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to send OTP.")));
      }
    });
  }

  void verifyOTP() {
    if (otpController.text.trim() == _generatedOtp) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("OTP verified!")));
      Navigator.pushReplacementNamed(context, RoutesName.signupScreen, arguments: {
        'email': emailController.text.trim(),
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Incorrect OTP.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color(0xFF4CAF50); // Fresh Green
    final accentColor = Color(0xFF81C784); // Light Green

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          "OTP Verification",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Secure Your Account",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Please enter your email address to receive a One-Time Password (OTP).",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 30),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email Address",
                prefixIcon: Icon(Icons.email, color: primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : sendOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                  "Send OTP",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            if (_otpSent) ...[
              SizedBox(height: 40),
              Text(
                "Enter OTP",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: otpController,
                decoration: InputDecoration(
                  labelText: "OTP",
                  prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: verifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Verify OTP",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
