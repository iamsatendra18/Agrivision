import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utiles/routes/routes_name.dart';

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
  String selectedRole = 'User';
  bool acceptTerms = false;

  bool _showPassword = false;
  bool _showConfirmPassword = false;

  final String passwordPattern = r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';
  final String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  final String phonePattern = r'^\d{10}$';

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    } else if (!RegExp(passwordPattern).hasMatch(value)) {
      return 'Password must include uppercase, lowercase, number & special character';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    } else if (!RegExp(emailPattern).hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    } else if (!RegExp(phonePattern).hasMatch(value)) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscureText = false,
        IconData? icon,
        String? Function(String?)? validator,
        bool isPassword = false,
        bool showPassword = false,
        VoidCallback? togglePassword}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? !showPassword : obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: Color(0xFF2E7D32)) : null,
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            showPassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: togglePassword,
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Color(0xFFE8F5E9),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Color(0xFFF1F8E9),
      appBar: AppBar(
        title: Text('Sign Up'),
        centerTitle: true,
        backgroundColor: Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  'Create Your Account',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                ),
                SizedBox(height: 10),
                Text(
                  'Join AgriVision today!',
                  style: TextStyle(fontSize: 16, color: Colors.green[700]),
                ),
                SizedBox(height: 20),
                _buildTextField('Full Name', fullNameController, icon: Icons.person),
                SizedBox(height: 12),
                _buildTextField('Address', addressController, icon: Icons.location_on),
                SizedBox(height: 12),
                _buildTextField('Phone Number', phoneController, icon: Icons.phone, validator: validatePhone),
                SizedBox(height: 12),
                _buildTextField('Email', emailController, icon: Icons.email, validator: validateEmail),
                SizedBox(height: 12),
                _buildTextField(
                  'Password',
                  passwordController,
                  obscureText: true,
                  icon: Icons.lock,
                  validator: validatePassword,
                  isPassword: true,
                  showPassword: _showPassword,
                  togglePassword: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                ),
                SizedBox(height: 12),
                _buildTextField(
                  'Confirm Password',
                  confirmPasswordController,
                  obscureText: true,
                  icon: Icons.lock,
                  isPassword: true,
                  showPassword: _showConfirmPassword,
                  togglePassword: () {
                    setState(() {
                      _showConfirmPassword = !_showConfirmPassword;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Confirm Password is required';
                    if (value != passwordController.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  items: ['User', 'Trader'].map((role) {
                    return DropdownMenuItem<String>(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedRole = value!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: "Select Role",
                    prefixIcon: Icon(Icons.work, color: Color(0xFF2E7D32)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Color(0xFFE8F5E9),
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Checkbox(
                      value: acceptTerms,
                      activeColor: Color(0xFF2E7D32),
                      onChanged: (value) {
                        setState(() {
                          acceptTerms = value!;
                        });
                      },
                    ),
                    Expanded(
                      child: Text(
                        "I accept the terms and conditions",
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                authProvider.isLoading
                    ? CircularProgressIndicator()
                    : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (_formKey.currentState!.validate() && acceptTerms) {
                        try {
                          await authProvider.signup(
                            fullNameController.text.trim(),
                            addressController.text.trim(),
                            phoneController.text.trim(),
                            emailController.text.trim(),
                            passwordController.text.trim(),
                            selectedRole,
                            context,
                          );

                          // 🔁 Redirect to OTP screen with email
                          Navigator.pushNamed(
                            context,
                            RoutesName.otpScreen,
                            arguments: {'email': emailController.text.trim()},
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Signup failed: ${e.toString()}")),
                          );
                        }
                      }
                    },
                    icon: Icon(Icons.app_registration, color: Colors.white),
                    label: Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Color(0xFF2E7D32),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account?"),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Login", style: TextStyle(color: Color(0xFF2E7D32))),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
