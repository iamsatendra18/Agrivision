import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CropRecommendationTab extends StatefulWidget {
  @override
  _CropRecommendationTabState createState() => _CropRecommendationTabState();
}

class _CropRecommendationTabState extends State<CropRecommendationTab> {
  final TextEditingController _cropController = TextEditingController();
  final TextEditingController _soilController = TextEditingController();

  String selectedMonth = _getCurrentMonth();
  String? selectedLocation;

  String? editingDocId; // Track which doc is being edited
  bool isLoading = false;

  final List<String> locations = [
    'madhesh', 'bagmati', 'gandaki', 'lumbini', 'koshi', 'karnali', 'sudurpaschim'
  ];

  static String _getCurrentMonth() {
    final now = DateTime.now();
    return [
      'january', 'february', 'march', 'april', 'may', 'june',
      'july', 'august', 'september', 'october', 'november', 'december'
    ][now.month - 1];
  }

  Future<void> _submitRecommendation() async {
    final cropText = _cropController.text.trim();
    final soilType = _soilController.text.trim();
    final location = selectedLocation?.trim().toLowerCase() ?? '';
    final user = FirebaseAuth.instance.currentUser;

    if (cropText.isEmpty || location.isEmpty || soilType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('⚠️ Please enter all fields (location, soil type, crops).'),
        backgroundColor: Colors.orange,
      ));
      return;
    }

    setState(() => isLoading = true);

    try {
      final docId = editingDocId ?? "$selectedMonth-$location";
      await FirebaseFirestore.instance
          .collection('crop_recommendations')
          .doc(docId)
          .set({
        'month': selectedMonth,
        'location': location,
        'soilType': soilType,
        'crops': cropText,
        'createdBy': user?.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(editingDocId == null
            ? '✅ Recommendation added for $selectedMonth - $location'
            : '✏️ Recommendation updated for $selectedMonth - $location'),
        backgroundColor: editingDocId == null ? Colors.green : Colors.blue,
      ));

      _resetForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('❌ Failed: $e'),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _resetForm() {
    _cropController.clear();
    _soilController.clear();
    setState(() {
      selectedLocation = null;
      editingDocId = null;
    });
  }

  Future<void> _deleteRecommendation(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('crop_recommendations').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('🗑️ Deleted $docId'),
        backgroundColor: Colors.red,
      ));
      if (editingDocId == docId) {
        _resetForm();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('❌ Failed to delete: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _editRecommendation(Map<String, dynamic> data, String docId) {
    setState(() {
      selectedMonth = data['month'];
      selectedLocation = data['location'];
      _soilController.text = data['soilType'];
      _cropController.text = data['crops'];
      editingDocId = docId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Crop Recommendations'), backgroundColor: Colors.green[700]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Month', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: selectedMonth,
              isExpanded: true,
              items: List.generate(12, (index) {
                final month = [
                  'january', 'february', 'march', 'april', 'may', 'june',
                  'july', 'august', 'september', 'october', 'november', 'december'
                ][index];
                return DropdownMenuItem(value: month, child: Text(month.toUpperCase()));
              }),
              onChanged: (value) => setState(() => selectedMonth = value!),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedLocation,
              decoration: InputDecoration(
                labelText: 'Select Location',
                border: OutlineInputBorder(),
              ),
              items: locations.map((location) {
                return DropdownMenuItem(
                  value: location,
                  child: Text(location[0].toUpperCase() + location.substring(1)),
                );
              }).toList(),
              onChanged: (value) => setState(() => selectedLocation = value),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _soilController,
              decoration: InputDecoration(
                labelText: 'Soil Type (e.g. Loam, Sandy, Clay)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _cropController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Recommended Crops',
                hintText: 'Wheat, Rice, Bajra',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : _submitRecommendation,
                    icon: Icon(editingDocId == null ? Icons.save : Icons.edit),
                    label: Text(editingDocId == null ? 'Save Recommendation' : 'Update Recommendation'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ),
                if (editingDocId != null) ...[
                  SizedBox(width: 8),
                  IconButton(
                    onPressed: _resetForm,
                    icon: Icon(Icons.clear, color: Colors.red),
                  ),
                ]
              ],
            ),
            Divider(height: 30),
            Text('Previous Recommendations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('crop_recommendations')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) return Text("No history available");
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 6),
                      color: editingDocId == doc.id ? Colors.green[50] : null,
                      child: ListTile(
                        title: Text(
                          "${data['month'].toString().toUpperCase()} - ${data['location']}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Soil: ${data['soilType'] ?? 'N/A'}\nCrops: ${data['crops'] ?? ''}",
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editRecommendation(data, doc.id),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteRecommendation(doc.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
