import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TraderCropRecommendationScreen extends StatefulWidget {
  @override
  _TraderCropRecommendationScreenState createState() =>
      _TraderCropRecommendationScreenState();
}

class _TraderCropRecommendationScreenState
    extends State<TraderCropRecommendationScreen> {
  String selectedLocation = 'madhesh';
  String? selectedMonth;

  final List<String> months = [
    'january',
    'february',
    'march',
    'april',
    'may',
    'june',
    'july',
    'august',
    'september',
    'october',
    'november',
    'december'
  ];

  final List<String> availableLocations = [
    'madhesh',
    'bagmati',
    'gandaki',
    'koshi',
    'lumbini',
    'karnali',
    'sudurpaschim'
  ];

  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crop Recommendations'),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Select Location", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            DropdownButton<String>(
              value: selectedLocation,
              isExpanded: true,
              items: availableLocations.map((loc) {
                return DropdownMenuItem(
                  value: loc,
                  child: Text(loc.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) => setState(() => selectedLocation = value!),
            ),
            SizedBox(height: 20),
            Text("Select Month", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: months.map((month) {
                return ChoiceChip(
                  label: Text(month.toUpperCase()),
                  selected: selectedMonth == month,
                  onSelected: (_) => setState(() => selectedMonth = month),
                  selectedColor: Colors.green[200],
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            if (selectedMonth != null)
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('crop_recommendations')
                      .where('month', isEqualTo: selectedMonth)
                      .where('location', isEqualTo: selectedLocation.toLowerCase())
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          "No recommendation found for ${selectedMonth!} in ${selectedLocation.toUpperCase()}",
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    final docs = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data = doc.data() as Map<String, dynamic>;

                        final crops = data['crops'] ?? 'No crops';
                        final soil = data['soilType'] ?? 'N/A';
                        final createdBy = data['createdBy'];

                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          color: Colors.grey[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${selectedMonth!} - ${selectedLocation.toUpperCase()}",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[800]),
                                ),
                                SizedBox(height: 8),
                                Text("Soil Type: $soil", style: TextStyle(fontSize: 14)),
                                SizedBox(height: 4),
                                Text("Crops: $crops", style: TextStyle(fontSize: 14)),
                                if (createdBy == currentUser?.uid)
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _confirmDelete(doc.id),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(String docId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Delete Recommendation"),
        content: Text("Are you sure you want to delete this recommendation?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('crop_recommendations')
                  .doc(docId)
                  .delete();

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("✅ Recommendation deleted."),
                backgroundColor: Colors.red,
              ));
              setState(() {
                // optional reset
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
