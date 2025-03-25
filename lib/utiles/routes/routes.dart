import 'package:agrivision/screens/auth/forget_password_screen.dart'
    show ForgotPasswordScreen;
import 'package:agrivision/screens/trader/home_page.dart';
import 'package:agrivision/screens/user/cart_basket_screen.dart';
import 'package:agrivision/screens/user/home_screen.dart';
import 'package:agrivision/screens/auth/login_screen.dart';
import 'package:agrivision/screens/auth/signup_screen.dart';
import 'package:agrivision/screens/trader/trader_home_screen.dart'; // Ensure this file exists
import 'package:agrivision/screens/user/navigation_menu.dart';
import 'package:agrivision/screens/user/product_detail_screen.dart';
import 'package:agrivision/screens/user/user_profile_screen.dart';

import 'package:agrivision/utiles/routes/routes_name.dart';
import 'package:flutter/material.dart';

import '../../screens/auth/admin_login_screen.dart';
import '../../screens/trader/trader_add_product_screen.dart';
import '../../screens/trader/trader_climate_guidencess_screen.dart';
import '../../screens/trader/trader_contact_us_screen.dart';
import '../../screens/trader/trader_edit_product_screen.dart';
import '../../screens/trader/trader_notification_screen.dart';
import '../../screens/trader/trader_order_screen.dart';
import '../../screens/trader/trader_payment_screen.dart';
import '../../screens/trader/trader_profile_page.dart';
import '../../screens/trader/trader_service_screen.dart';
import '../../screens/user/user_notification_screen.dart';
import '../../screens/trader/trader_product_list_screen.dart';
import '../../screens/user/review_screen.dart';

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
      case RoutesName.reviewScreen: // 👈 Add this in your switch-case
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ReviewScreen(productId: args['productId']),
        );
      case RoutesName.userProfileScreen:
        return MaterialPageRoute(builder: (_) => UserProfileScreen());
      case RoutesName.traderProfilePage:
        return MaterialPageRoute(builder: (_) => TraderProfilePage());
      case RoutesName.cartBasketScreen:
        return MaterialPageRoute(builder: (_) => CartBasketScreen());
      case RoutesName.traderServiceScreen:
        return MaterialPageRoute(builder: (_) => TraderServiceScreen());
      case RoutesName.traderClimateGuidenessScreen:
        return MaterialPageRoute(
          builder: (_) => TraderClimateGuidencessScreen(),
        );
      case RoutesName.traderPaymentScreen:
        return MaterialPageRoute(builder: (_) => TraderPaymentScreen());
      case RoutesName.traderOrderScreen:
        return MaterialPageRoute(builder: (_) => TraderOrderScreen());
      case RoutesName.traderAddProductScreen:
        return MaterialPageRoute(builder: (_) => TraderAddProductScreen());
      case RoutesName.traderEditProductScreen:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => TraderEditProductScreen(productId: args['productId']),
        );

      case RoutesName.traderContactUsScreen:
        return MaterialPageRoute(builder: (_) => TraderContactUsScreen());
      case RoutesName.traderNotificationScreen:
        return MaterialPageRoute(builder: (_) => TraderNotificationScreen());
      case RoutesName.userNotificationScreen:
        return MaterialPageRoute(builder: (_) => UserNotificationScreen());
      case RoutesName.traderProductListScreen:
        return MaterialPageRoute(builder: (_) => TraderProductListScreen());
      case RoutesName.productDetailScreen:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ProductDetailScreen(),
          settings: RouteSettings(arguments: args),
        );

      case RoutesName.homePage:
        return MaterialPageRoute(builder: (_) => HomePage());
      case RoutesName.adminLoginScreen:
        return MaterialPageRoute(builder: (_) => AdminLoginScreen());
      case RoutesName.adminDashboardScreen:
        return MaterialPageRoute(builder: (_) => HomePage());

      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(body: Center(child: Text('No routes defined'))),
        );
    }
  }
}
