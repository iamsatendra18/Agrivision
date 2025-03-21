import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //drawer: _buildDrawer(context), // Burger Menu Drawer
      appBar: AppBar(
        title: Text("AgriVision - Home"),
        backgroundColor: Colors.green[700],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Section
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/farm_banner.jpg'), // Add an image to assets
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: Text(
                    "Welcome to AgriVision",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Greeting Message
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _getGreetingMessage(),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[800]),
              ),
            ),
            SizedBox(height: 10),

            // Live Weather & Market Info
            _buildLiveInfoSection(),

            // Quick Action Buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildActionButton(context, Icons.store, "Market", Colors.orange, () {}),
                  SizedBox(height: 10),
                  _buildActionButton(context, Icons.cloud, "Weather", Colors.blue, () {}),
                  SizedBox(height: 10),
                  _buildActionButton(context, Icons.grass, "Crop Guide", Colors.green, () {}),
                  SizedBox(height: 10),
                  _buildActionButton(context, Icons.support_agent, "Support", Colors.red, () {}),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Tips Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "🌱 Farming Tips:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 5),
            _buildTipCard("Use organic fertilizers to improve soil quality.", Icons.agriculture),
            _buildTipCard("Rotate crops to maintain soil nutrients.", Icons.swap_horiz),
            _buildTipCard("Monitor weather updates for best planting time.", Icons.cloud_queue),
          ],
        ),
      ),
    );
  }

  // Function to Get Greeting Message Based on Time of Day
  String _getGreetingMessage() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good Morning, Farmer! 🌅";
    } else if (hour < 17) {
      return "Good Afternoon, Farmer! ☀️";
    } else {
      return "Good Evening, Farmer! 🌙";
    }
  }

  // Function to Build Quick Action Buttons
  Widget _buildActionButton(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: TextStyle(fontSize: 16)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onTap,
    );
  }

  // Function to Build Farming Tip Cards
  Widget _buildTipCard(String tip, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              Icon(icon, color: Colors.green),
              SizedBox(width: 10),
              Expanded(child: Text(tip, style: TextStyle(fontSize: 16))),
            ],
          ),
        ),
      ),
    );
  }

  // Function to Display Live Weather & Market Price Info
  Widget _buildLiveInfoSection() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Weather Info
          _buildInfoCard(
            icon: Icons.thermostat,
            title: "Weather",
            value: "27°C 🌤️",
            color: Colors.blue,
          ),
          // Market Prices
          _buildInfoCard(
            icon: Icons.attach_money,
            title: "Wheat Price",
            value: "₹2,000/Q",
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  // Function to Build Small Information Cards
  Widget _buildInfoCard({required IconData icon, required String title, required String value, required Color color}) {
    return Expanded(
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 30),
              SizedBox(height: 5),
              Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              Text(value, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
