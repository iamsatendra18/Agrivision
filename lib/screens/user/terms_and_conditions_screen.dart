import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Terms and Conditions"),
        backgroundColor: Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            '''
AgriVision - Terms and Conditions

Last updated: March 30, 2025

By downloading or using the AgriVision app, you agree to the following terms:

1. Use of the App
- You agree to use this app for lawful purposes only.
- You must not misuse or tamper with the app or attempt unauthorized access.

2. Account Responsibility
- You are responsible for maintaining the confidentiality of your login details.
- AgriVision is not liable for any loss arising from unauthorized use of your account.

3. Transactions, Data and Privacy
- All transactions are between users and traders.
- AgriVision is responsible for delivery, payment disputes, or product quality. 
- Refer to our Privacy Policy to understand how we collect and use your information.

5. Intellectual Property & Modifications
- All content in the app (logo, text, design) is the property of AgriVision.
- You may not copy or use the content without permission.
- AgriVision reserves the right to change the terms at any time without notice.

7. Contact
- If you have any questions, reach out to us via the "Contact Us" screen.

Thank you for using AgriVision!
            ''',
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
        ),
      ),
    );
  }
}
