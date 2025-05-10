import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClimateGuidenessTab extends StatefulWidget {
  @override
  _ClimateGuidenessTabState createState() => _ClimateGuidenessTabState();
}

class _ClimateGuidenessTabState extends State<ClimateGuidenessTab> {
  List<_ClimateCardData> guidanceCards = [];

  @override
  void initState() {
    super.initState();
    _fetchClimateGuidance();
  }

  Future<void> _fetchClimateGuidance() async {
    final snapshot =
    await FirebaseFirestore.instance.collection('climate_guidance').get();

    setState(() {
      guidanceCards = snapshot.docs.map((doc) {
        return _ClimateCardData(
          id: doc.id,
          icon: _getIconForTitle(doc['title']),
          title: doc['title'],
          description: doc['description'],
        );
      }).toList();
    });
  }

  IconData _getIconForTitle(String title) {
    switch (title) {
      case 'Weather Forecast':
        return Icons.wb_sunny_outlined;
      case 'Best Crop to Plant':
        return Icons.grass;
      case 'Irrigation Advice':
        return Icons.opacity;
      case 'Pest & Disease Alert':
        return Icons.bug_report_outlined;
      default:
        return Icons.info_outline;
    }
  }

  void _showEditDialog(_ClimateCardData card) {
    final TextEditingController _controller =
    TextEditingController(text: card.description);

    showDialog(
      context: context,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        return AlertDialog(
          title: Text('Update ${card.title}'),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 300,
              maxWidth: screenWidth * 0.9,
            ),
            child: TextField(
              controller: _controller,
              maxLines: 5,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter updated guidance',
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                String updatedText = _controller.text.trim();
                if (updatedText.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('climate_guidance')
                      .doc(card.id)
                      .update({'description': updatedText});

                  Navigator.pop(context);
                  _fetchClimateGuidance();

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('${card.title} updated successfully'),
                    backgroundColor: Colors.green,
                  ));
                }
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCard(_ClimateCardData card) {
    return GestureDetector(
      onTap: () => _showEditDialog(card),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(card.icon, size: 30, color: Colors.green),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.title,
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 6),
                    Text(
                      card.description,
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              Icon(Icons.edit, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Climate Guidance'),
        backgroundColor: Color(0xFF2E7D32),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: guidanceCards.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              // Tablet/Desktop
              return GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 3,
                children:
                guidanceCards.map((card) => _buildCard(card)).toList(),
              );
            } else {
              // Mobile
              return ListView.builder(
                itemCount: guidanceCards.length,
                itemBuilder: (context, index) =>
                    _buildCard(guidanceCards[index]),
              );
            }
          },
        ),
      ),
    );
  }
}

class _ClimateCardData {
  final String id;
  final IconData icon;
  final String title;
  final String description;

  _ClimateCardData({
    required this.id,
    required this.icon,
    required this.title,
    required this.description,
  });
}
