import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucide_icons/lucide_icons.dart';

class TraderClimateGuidencessScreen extends StatefulWidget {
  @override
  State<TraderClimateGuidencessScreen> createState() => _TraderClimateGuidencessScreenState();
}

class _TraderClimateGuidencessScreenState extends State<TraderClimateGuidencessScreen> {
  List<_ClimateCardData> guidanceCards = [];

  @override
  void initState() {
    super.initState();
    _fetchLatestGuidance();
  }

  Future<void> _fetchLatestGuidance() async {
    final snapshot = await FirebaseFirestore.instance.collection('climate_guidance').get();

    setState(() {
      guidanceCards = snapshot.docs.map((doc) {
        return _ClimateCardData(
          icon: _getLucideIcon(doc['title']),
          title: doc['title'],
          description: doc['description'],
        );
      }).toList();
    });
  }

  IconData _getLucideIcon(String title) {
    switch (title) {
      case 'Weather Forecast':
        return LucideIcons.cloudRain;
      case 'Best Crop to Plant':
        return LucideIcons.leaf;
      case 'Irrigation Advice':
        return LucideIcons.droplet;
      case 'Pest & Disease Alert':
        return LucideIcons.bug;
      default:
        return LucideIcons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: Text('Climate Guidance', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[700],
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: guidanceCards.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: guidanceCards.length,
        itemBuilder: (context, index) {
          final card = guidanceCards[index];
          return GestureDetector(
            onTap: () => _showPopupDialog(context, card.title, card.description),
            child: Card(
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
                  child: Icon(card.icon, color: Colors.green[700], size: 30),
                ),
                title: Text(card.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: Text(card.description, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showPopupDialog(BuildContext context, String title, String description) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 100),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, size: 40, color: Colors.green[700]),
                SizedBox(height: 10),
                Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                SizedBox(height: 16),
                Text(description, style: TextStyle(fontSize: 16, color: Colors.black87), textAlign: TextAlign.center),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
                  onPressed: () => Navigator.pop(context),
                  child: Text("Close", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ClimateCardData {
  final IconData icon;
  final String title;
  final String description;

  _ClimateCardData({
    required this.icon,
    required this.title,
    required this.description,
  });
}
