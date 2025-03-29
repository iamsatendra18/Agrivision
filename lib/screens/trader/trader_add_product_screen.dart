import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TraderAddProductScreen extends StatefulWidget {
  @override
  _TraderAddProductScreenState createState() => _TraderAddProductScreenState();
}

class _TraderAddProductScreenState extends State<TraderAddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  String productName = '';
  String description = '';
  String? selectedCategory;
  String imageUrl = '';
  double price = 0;
  double quantity = 0;
  bool _isLoading = false;

  final List<String> _categories = [
    'Fruits', 'Vegetables', 'Crops', 'Dairy Products',
    'Spinach', 'Grains', 'Herbs', 'Others',
  ];

  void _updateImagePreview(String url) {
    setState(() {
      imageUrl = url;
    });
  }

  bool _isValidImageUrl(String url) {
    return (Uri.tryParse(url)?.hasAbsolutePath == true &&
        (url.endsWith('.jpg') ||
            url.endsWith('.jpeg') ||
            url.endsWith('.png') ||
            url.endsWith('.webp'))) ||
        url.startsWith('assets/');
  }

  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    final currentUser = FirebaseAuth.instance.currentUser;

    // Check for critical nulls before proceeding
    if (selectedCategory == null || imageUrl.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Please fill all required fields properly.")),
      );
      return;
    }

    if (!_isValidImageUrl(imageUrl)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Please enter a valid image URL or asset path.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('products').add({
        'name': productName,
        'description': description,
        'price': price,
        'quantity': quantity,
        'category': selectedCategory,
        'imageUrl': imageUrl,
        'isVerified': false,
        'createdBy': currentUser?.uid ?? 'Unknown',
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Product submitted for admin verification.")),
      );

      _formKey.currentState?.reset();
      setState(() {
        selectedCategory = null;
        imageUrl = '';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to add product: ${e.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Product'),
        backgroundColor: Colors.green.shade700,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 20),
            _buildProductForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.agriculture, color: Colors.green, size: 40),
        SizedBox(width: 10),
        Text(
          "Add Your Product",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildProductForm() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField("Product Name", "Enter product name", (value) => productName = value),
              _buildCategoryDropdown(),
              _buildTextField("Quantity (kg/liter)", "Enter quantity",
                      (value) => quantity = double.tryParse(value) ?? 0, keyboardType: TextInputType.number),
              _buildTextField("Price (₹)", "Enter price",
                      (value) => price = double.tryParse(value) ?? 0, keyboardType: TextInputType.number),
              _buildTextField("Description", "Enter product description", (value) => description = value, maxLines: 3),
              _buildImageUrlField(),
              _buildImagePreview(),
              SizedBox(height: 20),

              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: "Category",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        value: selectedCategory,
        items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
        onChanged: (val) => setState(() => selectedCategory = val),
        validator: (val) => val == null ? "Please select a category" : null,
      ),
    );
  }

  Widget _buildTextField(String label, String hint, Function(String) onSaved,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: TextFormField(
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (value) => value == null || value.isEmpty ? "$label is required" : null,
        onSaved: (value) => onSaved(value ?? ""),
      ),
    );
  }

  Widget _buildImageUrlField() {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: "Image URL or Asset Path",
          hintText: "e.g. https://... or assets/your_image.jpg",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return "Image URL is required";
          if (!_isValidImageUrl(value)) return "Enter a valid image URL or asset path";
          return null;
        },
        onChanged: _updateImagePreview,
        onSaved: (value) => imageUrl = value ?? '',
      ),
    );
  }

  Widget _buildImagePreview() {
    if (imageUrl.isEmpty || !_isValidImageUrl(imageUrl)) return SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: imageUrl.startsWith('assets/')
            ? Image.asset(imageUrl, height: 180, width: double.infinity, fit: BoxFit.cover)
            : Image.network(
          imageUrl,
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 180,
              color: Colors.grey[300],
              child: Center(child: Text("⚠️ Image not available")),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitProduct,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade700,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: EdgeInsets.symmetric(vertical: 14),
        ),
        child: Text("Submit for Approval", style: TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }
}