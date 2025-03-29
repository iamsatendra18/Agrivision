import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TraderContactUsScreen extends StatefulWidget {
  @override
  _TraderContactUsScreenState createState() => _TraderContactUsScreenState();
}

class _TraderContactUsScreenState extends State<TraderContactUsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _showSnackbar("Could not open the link.");
    }
  }

  void _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@agrivision.com',
      query: _encodeQueryParameters({
        'subject': 'Trader Support Request from AgriVision App',
      }),
    );
    if (!await launchUrl(emailUri)) {
      _showSnackbar("Could not launch email.");
    }
  }

  void _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+9779817276496');
    if (!await launchUrl(phoneUri)) {
      _showSnackbar("Could not launch phone.");
    }
  }

  void _launchMaps() async {
    final Uri mapUri = Uri.parse("https://www.google.com/maps?q=AgriVision+Office,+Kathmandu,+Nepal");
    if (!await launchUrl(mapUri)) {
      _showSnackbar("Could not open Google Maps.");
    }
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _sendMessageToFirestore() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          _showSnackbar("Please login to send a message.");
          return;
        }

        await FirebaseFirestore.instance.collection('contact_messages').add({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'userId': user.uid,
          'message': _messageController.text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
        });

        _showSnackbar("Message Sent Successfully!");

        _nameController.clear();
        _emailController.clear();
        _messageController.clear();
      } catch (e) {
        _showSnackbar("Failed to send message. Please try again.");
      }
    } else {
      _showSnackbar("Please fill in all fields.");
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Us'),
        backgroundColor: Color(0xFF2E7D32),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Icon(Icons.support_agent, size: 60, color: Colors.green[700]),
                  SizedBox(height: 10),
                  Text("We're here to help!",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text("Contact us for any queries or assistance.",
                      style: TextStyle(fontSize: 16, color: Colors.black54)),
                ],
              ),
            ),
            SizedBox(height: 30),

            Text("Contact Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _contactTile(Icons.email, 'Email Us', _launchEmail),
                _contactTile(Icons.phone, 'Call Us', _launchPhone),
                _contactTile(Icons.location_on, 'Visit Us', _launchMaps),
              ],
            ),
            SizedBox(height: 30),

            Text("Connect With Us", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: FaIcon(FontAwesomeIcons.facebook, color: Colors.blue),
                  onPressed: () => _launchURL("https://www.facebook.com/satendra.kushwaha.399826"),
                ),
                IconButton(
                  icon: FaIcon(FontAwesomeIcons.instagram, color: Colors.purple),
                  onPressed: () => _launchURL("https://www.instagram.com/iam_sattu_18"),
                ),
                IconButton(
                  icon: FaIcon(FontAwesomeIcons.threads, color: Colors.black),
                  onPressed: () => _launchURL("https://www.threads.net"),
                ),
              ],
            ),
            SizedBox(height: 30),

            Text("Office Hours", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text("🕒 Monday - Sunday: 7:00 AM - 6:00 PM"),
            SizedBox(height: 30),

            Text("Send us a message", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    validator: (val) => val == null || val.trim().isEmpty ? 'Enter your name' : null,
                    decoration: InputDecoration(
                      hintText: 'Your Name',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),

                  SizedBox(height: 10),
                  TextFormField(
                    controller: _messageController,
                    validator: (val) => val == null || val.trim().isEmpty ? 'Enter your message' : null,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Your Message',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.preview),
                  label: Text("View Response"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: () {
                    _showSnackbar("Feature coming soon!");
                  },
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.send),
                  label: Text("Send Message"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: _sendMessageToFirestore,
                ),
              ],
            ),
            SizedBox(height: 50),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  "© 2025 Satendra Kushwaha\nAll rights reserved",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactTile(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Color(0xFFF1F8E9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: Color(0xFF2E7D32)),
            SizedBox(height: 8),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
