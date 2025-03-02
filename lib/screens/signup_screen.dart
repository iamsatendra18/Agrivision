import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Sign Up'),
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.4, // Adjust opacity as needed
              child: Image.asset(
                'assets/background.jpg', // Ensure you have this image in the assets folder
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextField(controller: fullNameController, decoration: InputDecoration(labelText: 'Full Name')),
                TextField(controller: addressController, decoration: InputDecoration(labelText: 'Address')),
                TextField(controller: phoneController, decoration: InputDecoration(labelText: 'Phone')),
                TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
                TextField(controller: passwordController, obscureText: true, decoration: InputDecoration(labelText: 'Password')),
                TextField(controller: confirmPasswordController, obscureText: true, decoration: InputDecoration(labelText: 'Confirm Password')),
                SizedBox(height: 20),
                authProvider.isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await authProvider.signup(
                        fullNameController.text,
                        addressController.text,
                        phoneController.text,
                        emailController.text,
                        passwordController.text,
                        context,
                      );
                    }
                  },
                  child: Text('Sign Up'),
                ),
              ],
            ),
          ),
        ),
        ]
      ),
    );
  }
}
