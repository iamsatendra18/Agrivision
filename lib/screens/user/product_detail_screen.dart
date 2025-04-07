import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agrivision/utiles/routes/routes_name.dart'; // Make sure this is imported

class ProductDetailScreen extends StatelessWidget {
  // Function to add product to cart under /cart/{userId}/items
  void _addToCart(BuildContext context, Map<String, dynamic> productData) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(' You are not logged in')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('cart')
          .doc(user.uid)
          .collection('items')
          .add({
        'name': productData['productName'],
        'price': productData['productPrice'],
        'quantity': 1,
        'imageUrl': productData['productImage'] ?? '',
        'addedAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Product added to cart!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Failed to add to cart: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    if (args == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Product Details'),
          backgroundColor: Color(0xFF2E7D32),
        ),
        body: Center(
          child: Text('No product details available.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(args['productName']),
        backgroundColor: Color(0xFF2E7D32),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: (args['productImage']?.toString().startsWith('assets/') ?? false)
                    ? Image.asset(args['productImage'], height: 200)
                    : Image.network(
                  args['productImage'],
                  height: 200,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset('assets/agrivision_logo.png', height: 200);
                  },
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                args['productName'],
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Text(
                'Rs. ${args['productPrice'].toStringAsFixed(2)} per KG',
                style: TextStyle(fontSize: 20, color: Colors.green),
              ),
              SizedBox(height: 8.0),
              Text(
                '${args['productQuantity'].toStringAsFixed(2)} Kg available',
                style: TextStyle(fontSize: 18, color: Colors.green[700]),
              ),
              SizedBox(height: 16.0),
              Text(
                args['productDescription'],
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16.0),

              /// Add to Cart Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _addToCart(context, args),
                  child: Text('Add to Cart'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),

              SizedBox(height: 10),

              /// Write a Review Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      RoutesName.reviewScreen,
                      arguments: {
                        'productId': args['productId'],
                      },
                    );
                  },
                  child: Text('Write a Review'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
