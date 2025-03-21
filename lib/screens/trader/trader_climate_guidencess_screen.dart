import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class TraderClimateGuidencessScreen extends StatelessWidget {
  final List<Map<String, dynamic>> climateGuidance = [
    {
      "title": "🌦️ Weather Forecast",
      "description": "Expect light showers tomorrow. Consider protecting your crops.",
      "icon": LucideIcons.cloudRain,
    },
    {
      "title": "🌾 Best Crop to Plant",
      "description": "This season is ideal for growing wheat and mustard.",
      "icon": LucideIcons.leaf,
    },
    {
      "title": "💧 Irrigation Advice",
      "description": "Reduce watering as humidity is high this week.",
      "icon": LucideIcons.droplet,
    },
    {
      "title": "🐛 Pest & Disease Alert",
      "description": "Monitor for locust swarms in nearby areas.",
      "icon": LucideIcons.bug,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: Text(
          'Climate Guidance',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[700],
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft), // Back button
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: climateGuidance.length,
        itemBuilder: (context, index) {
          return _buildGuidanceCard(climateGuidance[index]);
        },
      ),
    );
  }

  /// Climate Guidance Card Widget
  Widget _buildGuidanceCard(Map<String, dynamic> guidance) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.symmetric(vertical: 10),
      color: Colors.white,
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.green[100],
            shape: BoxShape.circle,
          ),
          child: Icon(
            guidance["icon"] as IconData,
            color: Colors.green[700],
            size: 30,
          ),
        ),
        title: Text(
          guidance["title"] ?? '',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          guidance["description"] ?? '',
          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
        ),
      ),
    );
  }
}
