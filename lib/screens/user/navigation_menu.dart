import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
        height: 80,
          elevation: 0,
          selectedIndex: navProvider.selectedIndex,
          onDestinationSelected: (int index) {
            navProvider.onItemTapped(index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.shopify),
              label: 'Shop',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_shopping_cart),
              label: 'Order',
            ),
            NavigationDestination(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ]
      ),
      body: navProvider.screens[navProvider.selectedIndex],
    );
  }

}