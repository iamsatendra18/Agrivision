import 'package:flutter/material.dart';
import 'package:agrivision/utiles/routes/routes_name.dart';

class TraderProfilePage extends StatefulWidget {
  const TraderProfilePage({super.key});

  @override
  _TraderProfilePageState createState() => _TraderProfilePageState();
}

class _TraderProfilePageState extends State<TraderProfilePage> {
  bool isEditing = false;
  final TextEditingController nameController =
  TextEditingController(text: 'Satendra Kushwaha');
  final TextEditingController addressController =
  TextEditingController(text: 'Baneshwor, Kathmandu');
  final TextEditingController phoneController =
  TextEditingController(text: '9817123456');
  final TextEditingController emailController =
  TextEditingController(text: 'satendrakushwaha2021@gmail.com');

  void toggleEdit() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      enabled: isEditing,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(Icons.edit, color: isEditing ? Color(0xFF2E7D32) : Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Color(0xFF2E7D32), width: 1.2),
        ),
        filled: true,
        fillColor: Color(0xFFE8F5E9), // Soft green background
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F8E9), // Light agriculture background
      appBar: AppBar(
        title: Text('User Profile'),
        centerTitle: true,
        backgroundColor: Color(0xFF2E7D32), // Deep Green Agriculture Theme
        foregroundColor: Colors.white, // White text for contrast
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
                      backgroundColor: Color(0xFF2E7D32), // Green Border
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage('assets/agrivision_logo.png'),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Satendra Singh',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                    ),
                    Text(
                      'Baneshwor, Kathmandu',
                      style: TextStyle(fontSize: 16, color: Colors.green[800]),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Text Fields
              buildTextField('Full Name', nameController),
              SizedBox(height: 12),
              buildTextField('Address', addressController),
              SizedBox(height: 12),
              buildTextField('Phone Number', phoneController),
              SizedBox(height: 12),
              buildTextField('Email', emailController),
              SizedBox(height: 20),

              // Edit Profile Button
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
                    backgroundColor: Color(0xFF1B5E20), // Deep Green for CTA
                    elevation: 5,
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Logout Button
            ],
          ),
        ),
      ),
    );
  }
}
