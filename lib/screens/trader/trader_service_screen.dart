import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';


class TraderServiceScreen extends StatelessWidget {
  final List<Map<String, dynamic>> services = [
    {
      "title": "🌱 Quality Seeds",
      "description": "Get high-yield seeds for better farming.",
      //"icon": LucideIcons.seedling
    },
    {
      "title": "💊 Fertilizers & Medicine",
      "description": "Organic and chemical fertilizers, pesticides, and crop protection.",
     // "icon": LucideIcons.flask
    },
    {
      "title": "🚜 Farm Equipment",
      "description": "Buy or rent tractors, irrigation tools, and more.",
      "icon": LucideIcons.wrench
    },

    {
      "title": "👨‍🌾 Expert Consultation",
      "description": "Talk to an agriculture expert for better farming solutions.",
      "icon": LucideIcons.userCheck
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: Text(
          'Farmer Services',
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
        itemCount: services.length,
        itemBuilder: (context, index) {
          return _buildServiceCard(services[index]);
        },
      ),
    );
  }

  /// Service Card Widget
  Widget _buildServiceCard(Map<String, dynamic> service) {
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
            service["icon"],
            color: Colors.green[700],
            size: 30,
          ),
        ),
        title: Text(
          service["title"] ?? '',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          service["description"] ?? '',
          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
        ),
      ),
    );
  }
}
