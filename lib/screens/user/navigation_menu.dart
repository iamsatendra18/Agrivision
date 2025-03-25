// navigation_menu.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/navigation_provider.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({Key? key}) : super(key: key);

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        height: 75,
        elevation: 10,
        backgroundColor: Color(0xFFE8F5E9),
        selectedIndex: navProvider.selectedIndex,
        indicatorColor: Color(0xFF1B5E20),
        onDestinationSelected: (int index) {
          if (FirebaseAuth.instance.currentUser == null && index != 0) {
            Navigator.pushNamed(context, 'login_screen'); // use RoutesName.loginScreen if preferred
          } else {
            navProvider.onItemTapped(index);
          }
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home, color: navProvider.selectedIndex == 0 ? Colors.white : Colors.green[900]),
            selectedIcon: Icon(Icons.home, color: Colors.white),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.shop, color: navProvider.selectedIndex == 1 ? Colors.white : Colors.green[900]),
            selectedIcon: Icon(Icons.shop, color: Colors.white),
            label: 'Shop',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart, color: navProvider.selectedIndex == 2 ? Colors.white : Colors.green[900]),
            selectedIcon: Icon(Icons.shopping_cart, color: Colors.white),
            label: 'Order',
          ),
          NavigationDestination(
            icon: Icon(Icons.person, color: navProvider.selectedIndex == 3 ? Colors.white : Colors.green[900]),
            selectedIcon: Icon(Icons.person, color: Colors.white),
            label: 'Profile',
          ),
        ],
      ),
      body: navProvider.screens[navProvider.selectedIndex],
    );
  }
}
