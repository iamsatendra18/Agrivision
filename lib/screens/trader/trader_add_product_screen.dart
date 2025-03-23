import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TraderAddProductScreen extends StatefulWidget {
  @override
  _TraderAddProductScreenState createState() => _TraderAddProductScreenState();
}

class _TraderAddProductScreenState extends State<TraderAddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  String? productName, description, selectedCategory;
  double? price, quantity;
  File? _image;

  final List<String> _categories = [
    'Fruits',
    'Vegetables',
    'Crops',
    'Dairy Products',
    'Spinach'
    'Grains',
    'Herbs',
    'Others',
  ];

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // 🔥 Function to save product to Firestore
  Future<void> _submitProduct() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final currentUser = FirebaseAuth.instance.currentUser;

      try {
        await FirebaseFirestore.instance.collection('products').add({
          'name': productName,
          'description': description,
          'price': price,
          'quantity': quantity,
          'category': selectedCategory,
          'imageUrl': '', // image upload will be handled later
          'createdBy': currentUser?.uid ?? 'Unknown',
          'createdAt': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Product added successfully!")),
        );

        _formKey.currentState!.reset();
        setState(() {
          _image = null;
          selectedCategory = null;
        });

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to add product: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Product'),
        backgroundColor: Colors.green.shade700,
        elevation: 0,
      ),
      body: SingleChildScrollView(
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
              _buildTextField("Product Name", "Enter product name", (value) {
                productName = value;
              }),
              _buildCategoryDropdown(),
              _buildTextField("Quantity (kg/liter)", "Enter quantity", (value) {
                quantity = double.tryParse(value);
              }, keyboardType: TextInputType.number),
              _buildTextField("Price (₹)", "Enter price", (value) {
                price = double.tryParse(value);
              }, keyboardType: TextInputType.number),
              _buildTextField("Description", "Enter product description", (value) {
                description = value;
              }, maxLines: 3),
              SizedBox(height: 15),
              _buildImageUploadSection(),
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        value: selectedCategory,
        items: _categories.map((category) {
          return DropdownMenuItem<String>(
            value: category,
            child: Text(category),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedCategory = value;
          });
        },
        validator: (value) => value == null ? "Please select a category" : null,
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: (value) => value!.isEmpty ? "$label is required" : null,
        onSaved: (value) => onSaved(value!),
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Upload Product Image",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: Center(
              child: _image == null
                  ? Icon(Icons.camera_alt, color: Colors.green, size: 40)
                  : Image.file(_image!, fit: BoxFit.cover),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitProduct,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade700,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.symmetric(vertical: 14),
        ),
        child: Text(
          "Add Product",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
