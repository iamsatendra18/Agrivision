import 'package:agrivision/screens/user/OrderHistoryScreen.dart';
import 'package:agrivision/screens/user/home_screen.dart';
import 'package:agrivision/screens/user/user_profile_screen.dart';
import 'package:flutter/cupertino.dart';

import '../screens/user/checkout_screen.dart';

class NavigationProvider extends ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;
  final List<Widget> _screens = [
    HomeScreen(),
    CheckoutScreen(),
    OrderHistoryScreen(),
    UserProfileScreen(),
    // HomeScreen(),
    // TraderHomeScreen(), // Add Trader Home Screen
    // ProfileScreen(),
    // CartScreen(),
    // OrdersScreen(),
    // NotificationsScreen(),
    // SettingsScreen(),
    // HelpScreen(),
    // AboutScreen(),
  ];

  List<Widget> get screens => _screens;

  void onItemTapped(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void onBacKPressed() {
    _selectedIndex = 0;
    notifyListeners();
  }

  Future<void> fetchData() async {
    switch (_selectedIndex){
      case 0:
        // await Provider.of<HomeProvider>(context, listen: false).fetchData();
        break;
      case 1:
        // await Provider.of<TraderHomeProvider>(context, listen: false).fetchData();
        break;
      case 2:
        // await Provider.of<ProfileProvider>(context, listen: false).fetchData();
        break;
      case 3:
        // await Provider.of<CartProvider>(context, listen: false).fetchData();
        break;
      case 4:
        // await Provider.of<OrdersProvider>(context, listen: false).fetchData();
        break;
      case 5:
        // await Provider.of<NotificationsProvider>(context, listen: false).fetchData();
        break;
      case 6:
        // await Provider.of<SettingsProvider>(context, listen: false).fetchData();
        break;
      case 7:
        // await Provider.of<HelpProvider>(context, listen: false).fetchData();
        break;
      case 8:
        // await Provider.of<AboutProvider>(context, listen: false).fetchData();
        break;
    }
  }
}