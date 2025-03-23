import 'package:agrivision/utiles/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadUserEmailPassword();
  }

  void _loadUserEmailPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      rememberMe = prefs.getBool('remember_me') ?? false;
      if (rememberMe) {
        emailController.text = prefs.getString('email') ?? '';
        passwordController.text = prefs.getString('password') ?? '';
      }
    });
  }

  void _handleRememberMe(bool value) {
    rememberMe = value;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('remember_me', rememberMe);
      if (rememberMe) {
        prefs.setString('email', emailController.text);
        prefs.setString('password', passwordController.text);
      } else {
        prefs.remove('email');
        prefs.remove('password');
      }
    });
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscureText = false, IconData? icon}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: Color(0xFF2E7D32)) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Login to continue',
                  style: TextStyle(fontSize: 16, color: Colors.green[700]),
                ),
                SizedBox(height: 30),
                Image.asset('assets/agrivision_logo.png', width: 150, height: 150),
                SizedBox(height: 30),
                _buildTextField('Email', emailController, icon: Icons.email),
                SizedBox(height: 16),
                _buildTextField('Password', passwordController,
                    obscureText: true, icon: Icons.lock),
                SizedBox(height: 10),
                Row(
                  children: [
                    Checkbox(
                      value: rememberMe,
                      activeColor: Color(0xFF2E7D32),
                      onChanged: (value) {
                        setState(() {
                          _handleRememberMe(value!);
                        });
                      },
                    ),
                    Text('Remember Me'),
                    Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(
                          context, RoutesName.forgotPasswordScreen),
                      child: Text("Forgot Password?",
                          style: TextStyle(color: Color(0xFF2E7D32))),
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
                      await authProvider.login(
                        emailController.text.trim(),
                        passwordController.text.trim(),
                        context,
                      );
                    },
                    icon: Icon(Icons.login, color: Colors.white),
                    label: Text(
                      'Login',
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
                    Text("Don't have an account?"),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, RoutesName.signupScreen),
                      child:
                      Text("Sign up", style: TextStyle(color: Color(0xFF2E7D32))),
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
