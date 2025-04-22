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
    final success = await EmailOTPService.sendOtpEmail(
      emailController.text.trim(),
      otp,
    );

    setState(() {
      _isLoading = false;
      if (success) {
        _otpSent = true;
        _generatedOtp = otp;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("OTP sent successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to send OTP.")),
        );
      }
    });
  }

  void verifyOTP() {
    if (otpController.text.trim() == _generatedOtp) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("OTP verified!")),
      );

      // ✅ Navigate to login page after verification
      Navigator.pushReplacementNamed(context, RoutesName.loginScreen);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Incorrect OTP.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("OTP Verification")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Enter your Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : sendOTP,
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Send OTP"),
            ),
            if (_otpSent) ...[
              SizedBox(height: 30),
              TextField(
                controller: otpController,
                decoration: InputDecoration(labelText: "Enter OTP"),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: verifyOTP,
                child: Text("Verify OTP"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
