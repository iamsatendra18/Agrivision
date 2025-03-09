import 'package:agrivision/screens/auth/forget_password_screen.dart'
    show ForgotPasswordScreen;
import 'package:agrivision/screens/user/cart_basket_screen.dart';
import 'package:agrivision/screens/user/home_screen.dart';
import 'package:agrivision/screens/auth/login_screen.dart';
import 'package:agrivision/screens/auth/signup_screen.dart';
import 'package:agrivision/screens/trader_home_screen.dart'; // Ensure this file exists
import 'package:agrivision/screens/user/navigation_menu.dart';
import 'package:agrivision/screens/user/product_detail_screen.dart';
import 'package:agrivision/screens/user/user_profile_screen.dart';
import 'package:agrivision/utiles/routes/routes_name.dart';
import 'package:flutter/material.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutesName.homeScreen:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case RoutesName.traderHomeScreen:
        return MaterialPageRoute(
          builder: (_) => TraderHomeScreen(),
        ); // Ensure TraderHomeScreen exists
      case RoutesName.loginScreen:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case RoutesName.signupScreen:
        return MaterialPageRoute(builder: (_) => SignupScreen());
      case RoutesName.forgotPasswordScreen:
        return MaterialPageRoute(builder: (_) => ForgotPasswordScreen());
      case RoutesName.navigationMenu:
        return MaterialPageRoute(builder: (_) => NavigationMenu());
      case RoutesName.userProfileScreen:
        return MaterialPageRoute(builder: (_) => UserProfileScreen());
      case RoutesName.cartBasketScreen:
        return MaterialPageRoute(builder: (_) => CartBasketScreen());
      case RoutesName.productDetailScreen:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder:
              (_) => ProductDetailScreen(
                productName: args['productName'],
                productImage: args['productImage'],
                productDescription: args['productDescription'],
                productPrice: args['productPrice'],
                productQuantity: args['productQuantity'],
              ),
        );
      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(body: Center(child: Text('No routes defined'))),
        );
    }
  }
}
