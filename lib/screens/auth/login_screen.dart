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
  bool _showPassword = false;
  Map<String, dynamic>? redirectData;

  @override
  void initState() {
    super.initState();
    _loadUserEmailPassword();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      redirectData = args;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please login to continue")),
        );
      });
    }
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
    bool isPassword = label.toLowerCase().contains('password');

    return TextField(
      controller: controller,
      obscureText: isPassword ? !_showPassword : obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: Color(0xFF2E7D32)) : null,
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            _showPassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _showPassword = !_showPassword;
            });
          },
        )
            : null,
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 25),
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
                SizedBox(height: 5),
                Text(
                  'Login to continue',
                  style: TextStyle(fontSize: 16, color: Colors.green[700]),
                ),
                SizedBox(height: 16),
                Image.asset('assets/agrivision_logo.png', width: 250, height: 200),
                SizedBox(height: 16),
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
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(color: Color(0xFF2E7D32)),
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
                      await authProvider.login(
                        emailController.text.trim(),
                        passwordController.text.trim(),
                        context,
                        redirectData: redirectData,
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
                      onPressed: () => Navigator.pushNamed(
                          context, RoutesName.signupScreen),
                      child: Text(
                        "Sign up",
                        style: TextStyle(color: Color(0xFF2E7D32)),
                      ),
                    ),
                  ],
                ),
                // ✅ Admin Login Styled as Link
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, RoutesName.adminLoginScreen);
                  },
                  child: Text(
                    "Are you an admin? Login here",
                    style: TextStyle(
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
