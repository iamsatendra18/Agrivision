import 'package:agrivision/utiles/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'signup_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background Image with Opacity
          Positioned.fill(
            child: Opacity(
              opacity: 0.4, // Adjust opacity as needed
              child: Image.asset(
                'assets/background.jpg',
                // Ensure you have this image in the assets folder
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                  ),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(labelText: 'Password'),
                  ),
                  SizedBox(height: 20),
                  authProvider.isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                        onPressed: () async {
                          await authProvider.login(
                            emailController.text,
                            passwordController.text,
                            context,
                          );
                        },
                        child: Text('Login'),
                      ),
                  TextButton(
                    onPressed:
                        () =>
                            Navigator.pushNamed(context, RoutesName.homeScreen),
                    child: Text("Don't have an account? Sign up"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
