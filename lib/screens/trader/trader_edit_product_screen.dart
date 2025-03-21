import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class TraderEditProductScreen extends StatefulWidget {
  @override
  _TraderEditProductScreenState createState() => _TraderEditProductScreenState();
}

class _TraderEditProductScreenState extends State<TraderEditProductScreen> {
  File? _image;
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  final _formKey = GlobalKey<FormState>();
  String _productName = '';
  String _price = '';
  String _quantity = '';
  String _description = '';
  String _selectedCategory = 'Vegetables';

  final List<String> _categories = [
    'Vegetables',
    'Fruits',
    'Dairy',
    'Grains',
    'Herbs',
    'Others'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        backgroundColor: Colors.green[700],
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Text('Product Name', style: TextStyle(fontWeight: FontWeight.bold)),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Enter product name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter product name' : null,
                  onSaved: (value) => _productName = value!,
                ),
                SizedBox(height: 15),

                // Price
                Text('Price (in ₹)', style: TextStyle(fontWeight: FontWeight.bold)),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Enter price',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Please enter price' : null,
                  onSaved: (value) => _price = value!,
                ),
                SizedBox(height: 15),

                // Quantity
                Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold)),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Enter quantity (e.g., 10 kg, 5 pieces)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter quantity' : null,
                  onSaved: (value) => _quantity = value!,
                ),
                SizedBox(height: 15),

                // Category Selection
                Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: _categories.map((category) {
                    return DropdownMenuItem(value: category, child: Text(category));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                  decoration: InputDecoration(border: OutlineInputBorder()),
                ),
                SizedBox(height: 15),

                // Description
                Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Enter product description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
                  onSaved: (value) => _description = value!,
                ),
                SizedBox(height: 20),

                // Image Upload Box - Moved Below Description
                Text('Upload Product Image', style: TextStyle(fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green, width: 2),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.green[50],
                    ),
                    child: _image == null
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 40, color: Colors.green),
                          SizedBox(height: 5),
                          Text('Tap to upload image', style: TextStyle(color: Colors.green)),
                        ],
                      ),
                    )
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _image!,
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Save Button
                Center(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.save),
                    label: Text('Save Changes'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Product updated successfully!')),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
