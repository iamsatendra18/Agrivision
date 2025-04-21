// ✅ Admin Dashboard Screen with Fixed Route Reference
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agrivision/utiles/routes/routes_name.dart';

class AdminDashboardScreen extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, RoutesName.adminLoginScreen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        backgroundColor: Color(0xFF2E7D32),
      ),
      drawer: Drawer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(user?.displayName ?? 'Admin'),
                accountEmail: Text(user?.email ?? ''),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Color(0xFF2E7D32)),
                ),
                decoration: BoxDecoration(color: Color(0xFF2E7D32)),
              ),
              _buildDrawerItem(
                icon: Icons.dashboard,
                label: 'Dashboard',
                onTap: () => Navigator.pushReplacementNamed(context, RoutesName.adminDashboardScreen),
              ),
              _buildDrawerItem(
                icon: Icons.receipt_long,
                label: 'Order History',
                onTap: () => Navigator.pushNamed(context, RoutesName.orderHistoryTab),
              ),
              _buildDrawerItem(
                icon: Icons.payment,
                label: 'Payment History',
                onTap: () => Navigator.pushNamed(context, RoutesName.paymentsTab),
              ),
              _buildDrawerItem(
                icon: Icons.volunteer_activism,
                label: 'Anudan',
                onTap: () => Navigator.pushNamed(context, RoutesName.anudanMessagesTab),
              ),
              _buildDrawerItem(
                icon: Icons.people,
                label: 'Climate Guideness',
                onTap: () => Navigator.pushNamed(context, RoutesName.climateGuidenessTab),
              ),
              _buildDrawerItem(
                icon: Icons.agriculture,
                label: 'Crop Recommendation',
                onTap: () => Navigator.pushNamed(context, RoutesName.cropRecommendationTab),
              ),
              _buildDrawerItem(
                icon: Icons.check_circle,
                label: 'Verified Products',
                onTap: () => Navigator.pushNamed(context, RoutesName.verifiedProductsTab),
              ),
              _buildDrawerItem(
                icon: Icons.verified_user,
                label: 'Verified Traders',
                onTap: () => Navigator.pushNamed(context, RoutesName.verifiedTradersTab),
              ),
              _buildDrawerItem(
                icon: Icons.notifications,
                label: 'Notifications',
                onTap: () => Navigator.pushNamed(context, RoutesName.notificationsTab),
              ),
              _buildDrawerItem(
                icon: Icons.analytics,
                label: 'Analytics',
                onTap: () => Navigator.pushNamed(context, RoutesName.analyticsTab),
              ),
              _buildDrawerItem(
                icon: Icons.message,
                label: 'Contact Messages',
                onTap: () => Navigator.pushNamed(context, RoutesName.adminContactMessagesTab),
              ),
              const Divider(),
              _buildDrawerItem(
                icon: Icons.logout,
                label: 'Logout',
                onTap: () => _signOut(context),
              ),
            ],
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: Text(
              'Welcome to Admin Dashboard!',
              style: TextStyle(
                fontSize: constraints.maxWidth < 600 ? 24 : 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Color(0xFF2E7D32)),
      title: Text(label, style: TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }
}
