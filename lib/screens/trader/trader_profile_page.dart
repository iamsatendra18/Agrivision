import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final TextEditingController imageController = TextEditingController();

  final uid = FirebaseAuth.instance.currentUser?.uid;
  String imageUrl = '';

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
        (url.endsWith('.jpg') || url.endsWith('.jpeg') || url.endsWith('.png') || url.endsWith('.webp')))
        || url.startsWith('assets/');
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

  Widget buildImagePreview() {
    if (imageUrl.isEmpty || !_isValidImageUrl(imageUrl)) {
      return const CircleAvatar(
        radius: 50,
        backgroundImage: AssetImage('assets/agrivision_logo.png'),
      );
    }

    return CircleAvatar(
      radius: 50,
      backgroundImage: imageUrl.startsWith('assets/')
          ? AssetImage(imageUrl) as ImageProvider
          : NetworkImage(imageUrl),
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
              SizedBox(height: 12),
              buildTextField('Image URL or Asset Path', imageController),

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
