import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TraderPrivacyPolicyScreen extends StatelessWidget {
  final String defaultPolicyText = '''
AgriVision – Privacy Policy

Effective Date: March 30, 2025

At AgriVision, we are committed to protecting your personal data and respecting your privacy. This Privacy Policy outlines how we collect, use, store, and safeguard your information when you use our mobile application and related services.

1. Information We Collect

We may collect the following types of information:
- Personal Information: Full name, email address, mobile number, address, and profile details.
- Usage Data: App interaction data, search queries, features accessed, and session durations..
- Device Information: Device model, operating system, IP address, app version, and device identifiers.

2. How We Use Your Information

Your information is used for the following purposes:
- To personalize and enhance your app experience
- To process orders, manage user accounts, and handle transactions
- To communicate updates, alerts, and support responses
- To analyze trends and improve app performance and usability

3. Sharing of Data

We do not sell or rent your personal information.

We may share your data:
- With trusted third-party services (e.g., payment gateways, analytics providers) bound by confidentiality
- With government or law enforcement if required by legal obligation or regulation

4. Data Security

We use industry-standard security practices, including encryption, authentication, and access controls to protect your data. However, no system is entirely secure, and we cannot guarantee complete protection.

5. Your Rights and Choices

You have the right to:
- Access and update your personal data via your profile settings
- Request deletion of your account and associated data by contacting our support team
- Opt-out of non-essential communications

6. Changes to This Policy

We may update this Privacy Policy to reflect changes in law, technology, or our practices. We will notify you within the app for significant updates.

7. Contact Us

If you have any questions or concerns about this Privacy Policy, you can contact us:

📧 Email: support@agrivision.com  
📞 Phone: +977-9817276496

Thank you for trusting AgriVision to support your agricultural journey.
  ''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy'),
        backgroundColor: Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('app_settings')
            .doc('privacy_policy')
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          String policyText = defaultPolicyText;

          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            policyText = data['content'] ?? defaultPolicyText;
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Text(
                policyText,
                style: TextStyle(fontSize: 16, height: 1.6),
              ),
            ),
          );
        },
      ),
    );
  }
}
