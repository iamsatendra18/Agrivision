import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool isEditing = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController imageController = TextEditingController();

  final uid = FirebaseAuth.instance.currentUser?.uid;
  String imageUrl = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();
      if (data != null) {
        nameController.text = data['fullName'] ?? '';
        addressController.text = data['address'] ?? '';
        phoneController.text = data['phone'] ?? '';
        emailController.text = data['email'] ?? '';
        imageController.text = data['imageUrl'] ?? '';
        setState(() {
          imageUrl = data['imageUrl'] ?? '';
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'fullName': nameController.text.trim(),
        'address': addressController.text.trim(),
        'phone': phoneController.text.trim(),
        'imageUrl': imageController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully!')),
      );

      setState(() {
        imageUrl = imageController.text.trim();
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

  bool _isValidImageUrl(String url) {
    return (Uri.tryParse(url)?.hasAbsolutePath == true &&
        (url.endsWith('.jpg') || url.endsWith('.jpeg') || url.endsWith('.png') || url.endsWith('.webp'))) ||
        url.startsWith('assets/');
  }

  Widget buildTextField(String label, TextEditingController controller, {bool readOnly = false}) {
    return TextField(
      controller: controller,
      enabled: isEditing && !readOnly,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(Icons.edit, color: isEditing ? Color(0xFF2E7D32) : Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        filled: true,
        fillColor: Color(0xFFE8F5E9),
      ),
    );
  }

  Widget buildImagePreview() {
    if (imageUrl.isEmpty || !_isValidImageUrl(imageUrl)) {
      return const CircleAvatar(
        radius: 50,
        backgroundImage: AssetImage('assets/agrivision_logo.png'),
      );
    }

    return CircleAvatar(
      radius: 50,
      backgroundImage:
      imageUrl.startsWith('assets/') ? AssetImage(imageUrl) as ImageProvider : NetworkImage(imageUrl),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFFF1F8E9),
      appBar: AppBar(
        title: Text('User Profile', style: TextStyle(fontSize: screenWidth * 0.05)),
        centerTitle: true,
        backgroundColor: Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundColor: Color(0xFF2E7D32),
                      child: buildImagePreview(),
                    ),
                    SizedBox(height: 12),
                    Text(
                      nameController.text,
                      style: TextStyle(
                        fontSize: screenWidth * 0.055,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    Text(
                      addressController.text,
                      style: TextStyle(fontSize: screenWidth * 0.042, color: Colors.green[800]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              buildTextField('Full Name', nameController),
              const SizedBox(height: 12),
              buildTextField('Address', addressController),
              const SizedBox(height: 12),
              buildTextField('Phone Number', phoneController),
              const SizedBox(height: 12),
              buildTextField('Email', emailController, readOnly: true),
              const SizedBox(height: 12),
              buildTextField('Image URL or Asset Path', imageController),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: toggleEdit,
                  icon: Icon(isEditing ? Icons.save : Icons.edit, color: Colors.white),
                  label: Text(
                    isEditing ? 'Save Profile' : 'Edit Profile',
                    style: TextStyle(fontSize: screenWidth * 0.045, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
