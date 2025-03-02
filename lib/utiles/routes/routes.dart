import 'package:agrivision/screens/home_screen.dart';
import 'package:agrivision/screens/login_screen.dart';
import 'package:agrivision/screens/signup_screen.dart';
import 'package:agrivision/utiles/routes/routes_name.dart';
import 'package:flutter/material.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutesName.homeScreen:
        return MaterialPageRoute(
          builder: (BuildContext context) => HomeScreen(),
        );

      case RoutesName.loginScreen:
        return MaterialPageRoute(
          builder: (BuildContext context) => LoginScreen(),
        );

      case RoutesName.signupScreen:
        return MaterialPageRoute(
          builder: (BuildContext context) => SignupScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) {
            return Scaffold(body: Center(child: Text('No routes defined')));
          },
        );
    }
  }
}
