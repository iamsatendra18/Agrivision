import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agrivision/utiles/routes/routes_name.dart';

class TraderProfilePage extends StatefulWidget {
  const TraderProfilePage({super.key});

  @override
  _TraderProfilePageState createState() => _TraderProfilePageState();
}

class _TraderProfilePageState extends State<TraderProfilePage> {
  bool isEditing = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _loadTraderData();
  }

  Future<void> _loadTraderData() async {
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();
      if (data != null) {
        nameController.text = data['fullName'] ?? '';
        addressController.text = data['address'] ?? '';
        phoneController.text = data['phone'] ?? '';
        emailController.text = data['email'] ?? '';
      }
    }
  }

  Future<void> _saveProfile() async {
    if (uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'fullName': nameController.text.trim(),
        'address': addressController.text.trim(),
        'phone': phoneController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully!')),
      );

      setState(() {
        isEditing = false;
      });
    }
  }

  void toggleEdit() {
    if (isEditing) {
      _saveProfile();
    } else {
      setState(() {
        isEditing = true;
      });
    }
  }

  Widget buildTextField(String label, TextEditingController controller, {bool readOnly = false}) {
    return TextField(
      controller: controller,
      enabled: isEditing && !readOnly,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(Icons.edit, color: isEditing ? Color(0xFF2E7D32) : Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Color(0xFF2E7D32), width: 1.2),
        ),
        filled: true,
        fillColor: Color(0xFFE8F5E9),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F8E9),
      appBar: AppBar(
        title: Text('Trader Profile'),
        centerTitle: true,
        backgroundColor: Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Avatar Section
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundColor: Color(0xFF2E7D32),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage('assets/agrivision_logo.png'),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      nameController.text,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                    ),
                    Text(
                      addressController.text,
                      style: TextStyle(fontSize: 16, color: Colors.green[800]),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              buildTextField('Full Name', nameController),
              SizedBox(height: 12),
              buildTextField('Address', addressController),
              SizedBox(height: 12),
              buildTextField('Phone Number', phoneController),
              SizedBox(height: 12),
              buildTextField('Email', emailController, readOnly: true),

              SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: toggleEdit,
                  icon: Icon(isEditing ? Icons.save : Icons.edit, color: Colors.white),
                  label: Text(
                    isEditing ? 'Save Profile' : 'Edit Profile',
                    style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    backgroundColor: Color(0xFF1B5E20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
