import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../admin/view_response_screen.dart';

class ContactUsScreen extends StatefulWidget {
  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  void _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'satendrakushwaha2021@gmail.com',
      query: encodeQueryParameters(<String, String>{
        'subject': 'Support Inquiry from AgriVision App'
      }),
    );
    launchUrl(emailLaunchUri);
  }

  void _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+9779845957577');
    launchUrl(phoneUri);
  }

  void _launchMaps() async {
    final Uri mapUri = Uri.parse("https://www.google.com/maps/place/The+British+College,+Kathmandu/@27.6924364,85.3198468,18.46z/data=!4m9!1m2!2m1!1zLA!3m5!1s0x39eb19b19295555f:0xabfe5f4b310f97de!8m2!3d27.6921341!4d85.3195183!16s%2Fg%2F11bw8f8gc4?entry=ttu");
    launchUrl(mapUri);
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  Future<void> _submitMessage() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('contact_messages').add({
          'name': _nameController.text.trim(),
          'message': _messageController.text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
          'userId': FirebaseAuth.instance.currentUser?.uid ?? '',
          'role': 'User',
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message sent successfully!')),
        );

        _nameController.clear();
        _messageController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error sending message. Please try again.')),
        );
      }
    }
  }

  void _viewResponse() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ViewResponseScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: Row(
          children: [
            Image.asset('assets/agrivision_logo.png', height: screenWidth * 0.07),
            SizedBox(width: screenWidth * 0.02),
            Text('Contact Us', style: TextStyle(fontSize: screenWidth * 0.05)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(screenWidth * 0.04, 16, screenWidth * 0.04, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("We'd love to hear from you!", style: TextStyle(fontSize: screenWidth * 0.04)),
            SizedBox(height: screenWidth * 0.05),

            Text("Contact Information", style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold)),
            SizedBox(height: screenWidth * 0.03),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _contactTile(Icons.email, 'Email Us', _launchEmail, screenWidth),
                _contactTile(Icons.phone, 'Call Us', _launchPhone, screenWidth),
                _contactTile(Icons.location_on, 'Visit Us', _launchMaps, screenWidth),
              ],
            ),
            SizedBox(height: screenWidth * 0.06),

            Text("Connect With Us", style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold)),
            SizedBox(height: screenWidth * 0.03),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: FaIcon(FontAwesomeIcons.facebook, color: Colors.blue),
                  iconSize: screenWidth * 0.07,
                  onPressed: () => _launchURL("https://www.facebook.com/satendra.kushwaha.399826"),
                ),
                IconButton(
                  icon: FaIcon(FontAwesomeIcons.instagram, color: Colors.purple),
                  iconSize: screenWidth * 0.07,
                  onPressed: () => _launchURL("https://www.instagram.com/iam_sattu_18"),
                ),
                IconButton(
                  icon: FaIcon(FontAwesomeIcons.threads, color: Colors.black),
                  iconSize: screenWidth * 0.07,
                  onPressed: () => _launchURL("https://www.threads.net"),
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.06),

            Text("Office Hours", style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text("🕒 Monday - Sunday: 7:00 AM - 6:00 PM"),
            SizedBox(height: screenWidth * 0.1),

            SizedBox(height: screenWidth * 0.2),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  "© 2025 Satendra Kushwaha\nAll rights reserved",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: screenWidth * 0.035),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactTile(IconData icon, String title, VoidCallback onTap, double width) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: width * 0.4,
        padding: EdgeInsets.symmetric(vertical: width * 0.04),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F8E9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: width * 0.08, color: const Color(0xFF2E7D32)),
            SizedBox(height: 8),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
