import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agrivision/utiles/routes/routes_name.dart';

class TraderEditProductScreen extends StatefulWidget {
  final String productId;
  const TraderEditProductScreen({required this.productId});

  @override
  _TraderEditProductScreenState createState() => _TraderEditProductScreenState();
}

class _TraderEditProductScreenState extends State<TraderEditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  String _productName = '';
  String _description = '';
  String _selectedCategory = 'Vegetables';
  double _price = 0;
  double _quantity = 0;
  String _imageUrl = '';
  File? _newImageFile;
  bool _isLoading = true;

  final picker = ImagePicker();
  final List<String> _categories = [
    'Vegetables', 'Fruits', 'Dairy Products', 'Crops', 'Herbs', 'Grains', 'Spinach', 'Others'
  ];

  @override
  void initState() {
    super.initState();
    _loadProductData();
  }

  Future<void> _loadProductData() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('products').doc(widget.productId).get();
      final data = doc.data() as Map<String, dynamic>;
      setState(() {
        _productName = data['name'] ?? '';
        _description = data['description'] ?? '';
        _selectedCategory = data['category'] ?? 'Vegetables';
        _price = (data['price'] ?? 0).toDouble();
        _quantity = (data['quantity'] ?? 0).toDouble();
        _imageUrl = data['imageUrl'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading product: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _newImageFile = File(picked.path);
      });
    }
  }

  Future<String> _uploadImage(File image) async {
    final fileName = 'product_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = FirebaseStorage.instance.ref().child(fileName);
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  bool _isValidImageUrl(String url) {
    return (Uri.tryParse(url)?.hasAbsolutePath == true &&
        (url.endsWith('.jpg') || url.endsWith('.jpeg') || url.endsWith('.png') || url.endsWith('.webp')))
        || url.startsWith('assets/');
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    try {
      String imageUrlToUpdate = _imageUrl;

      if (_newImageFile != null) {
        imageUrlToUpdate = await _uploadImage(_newImageFile!);
      } else if (!_isValidImageUrl(_imageUrl)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid image URL or path.")),
        );
        setState(() => _isLoading = false);
        return;
      }

      await FirebaseFirestore.instance.collection('products').doc(widget.productId).update({
        'name': _productName,
        'description': _description,
        'price': _price,
        'quantity': _quantity,
        'category': _selectedCategory,
        'imageUrl': imageUrlToUpdate,
        'updatedAt': Timestamp.now(),
        'isVerified': false,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(" Product updated successfully!")),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        RoutesName.traderProductListScreen,
            (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(" Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Product"),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField("Product Name", _productName, (val) => _productName = val!),
                _buildTextField("Price (₹)", _price.toString(), (val) => _price = double.parse(val!), keyboardType: TextInputType.number),
                _buildTextField("Quantity", _quantity.toString(), (val) => _quantity = double.parse(val!), keyboardType: TextInputType.number),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val!),
                  decoration: InputDecoration(labelText: "Category", border: OutlineInputBorder()),
                ),
                SizedBox(height: 12),
                _buildTextField("Description", _description, (val) => _description = val!, maxLines: 3),
                _buildTextField("Image URL or Asset Path", _imageUrl, (val) => _imageUrl = val!),
                SizedBox(height: 12),
                _buildImagePreview(),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.save),
                    label: Text("Save Changes"),
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_newImageFile != null) {
      return Image.file(_newImageFile!, height: 150, fit: BoxFit.cover);
    }

    if (_imageUrl.isEmpty) {
      return SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: _imageUrl.startsWith('assets/')
          ? Image.asset(_imageUrl, height: 150, fit: BoxFit.cover)
          : Image.network(
        _imageUrl,
        height: 150,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset('assets/agrivision_logo.png', height: 150, fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildTextField(
      String label,
      String initialValue,
      FormFieldSetter<String> onSaved, {
        TextInputType keyboardType = TextInputType.text,
        int maxLines = 1,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: initialValue,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
        onSaved: onSaved,
      ),
    );
  }
}