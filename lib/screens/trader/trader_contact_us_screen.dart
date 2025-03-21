import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TraderContactUsScreen extends StatefulWidget {
  @override
  _TraderContactUsScreenState createState() => _TraderContactUsScreenState();
}

class _TraderContactUsScreenState extends State<TraderContactUsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri.parse("tel:+919876543210");
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      _showSnackbar("Could not launch phone.");
    }
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri.parse(
        "mailto:support@agrivision.com?subject=Support Request&body=Hello, I need help with...");
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      _showSnackbar("Could not launch email.");
    }
  }

  Future<void> _launchMaps() async {
    final Uri mapsUri = Uri.parse("https://www.google.com/maps?q=AgriVision+Office");
    if (await canLaunchUrl(mapsUri)) {
      await launchUrl(mapsUri);
    } else {
      _showSnackbar("Could not open Google Maps.");
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showResponseDialog() {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _messageController.text.isEmpty) {
      _showSnackbar("Please fill in all fields.");
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Message Preview"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Name: ${_nameController.text}", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              Text("Email: ${_emailController.text}", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              Text("Message:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(_messageController.text),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Edit"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showSnackbar("Message Sent Successfully!");
              },
              child: Text("Confirm & Send"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        );
      },
    );
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
        backgroundColor: Colors.green[700],
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Center(
                child: Column(
                  children: [
                    Icon(Icons.support_agent, size: 80, color: Colors.green[700]),
                    SizedBox(height: 10),
                    Text(
                      "We're here to help!",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Contact us for any queries or assistance.",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Contact Information
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green),
                ),
                child: Column(
                  children: [
                    // Phone
                    ListTile(
                      leading: Icon(Icons.phone, color: Colors.green[700]),
                      title: Text("+977 9817276496", style: TextStyle(fontSize: 16)),
                      subtitle: Text("Call us anytime"),
                      onTap: _launchPhone,
                    ),
                    Divider(),
                    // Email
                    ListTile(
                      leading: Icon(Icons.email, color: Colors.green[700]),
                      title: Text("support@agrivision.com", style: TextStyle(fontSize: 16)),
                      subtitle: Text("Send us an email"),
                      onTap: _launchEmail,
                    ),
                    Divider(),
                    // Address
                    ListTile(
                      leading: Icon(Icons.location_on, color: Colors.green[700]),
                      title: Text("AgriVision Office, Kathmandu, Nepal"),
                      subtitle: Text("Find us on Google Maps"),
                      onTap: _launchMaps,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Contact Form
              Text("Send Us a Message", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Your Name",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),

              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Your Email",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 10),

              TextFormField(
                controller: _messageController,
                decoration: InputDecoration(
                  labelText: "Your Message",
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              SizedBox(height: 20),

              // Buttons
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
                    onPressed: _showResponseDialog,
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.send),
                    label: Text("Send Message"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onPressed: () {
                      if (_nameController.text.isNotEmpty &&
                          _emailController.text.isNotEmpty &&
                          _messageController.text.isNotEmpty) {
                        _showSnackbar("Message Sent Successfully!");
                      } else {
                        _showSnackbar("Please fill in all fields.");
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
