import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agrivision/utiles/routes/routes_name.dart';

class ProductDetailScreen extends StatelessWidget {
  void _addToCart(BuildContext context, Map<String, dynamic> productData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('You are not logged in')));
      return;
    }

    final cartRef = FirebaseFirestore.instance
        .collection('cart')
        .doc(user.uid)
        .collection('items');

    final existing = await cartRef
        .where('productId', isEqualTo: productData['productId'])
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      await existing.docs.first.reference.update({
        'quantity': FieldValue.increment(1),
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Quantity updated in cart')));
    } else {
      await cartRef.add({
        'name': productData['productName'],
        'price': productData['productPrice'],
        'quantity': 1,
        'imageUrl': productData['productImage'] ?? '',
        'addedAt': Timestamp.now(),
        'traderId': productData['traderId'],
        'productId': productData['productId'],
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Product added to cart!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    final screenWidth = MediaQuery.of(context).size.width;

    if (args == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Product Details'),
          backgroundColor: const Color(0xFF2E7D32),
        ),
        body: Center(child: Text('No product details available.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(args['productName'], style: TextStyle(fontSize: screenWidth * 0.05)),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: (args['productImage']?.toString().startsWith('assets/') ?? false)
                  ? Image.asset(args['productImage'], height: screenWidth * 0.5)
                  : Image.network(
                args['productImage'],
                height: screenWidth * 0.5,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset('assets/agrivision_logo.png', height: screenWidth * 0.5);
                },
              ),
            ),
            SizedBox(height: screenWidth * 0.04),
            Text(
              args['productName'],
              style: TextStyle(fontSize: screenWidth * 0.06, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: screenWidth * 0.02),
            Text(
              'Rs. ${args['productPrice'].toStringAsFixed(2)} per KG',
              style: TextStyle(fontSize: screenWidth * 0.05, color: Colors.green),
            ),
            SizedBox(height: screenWidth * 0.01),
            Text(
              '${args['productQuantity'].toStringAsFixed(2)} Kg available',
              style: TextStyle(fontSize: screenWidth * 0.045, color: Colors.green[700]),
            ),
            SizedBox(height: screenWidth * 0.04),
            Text(
              args['productDescription'],
              style: TextStyle(fontSize: screenWidth * 0.043),
            ),
            SizedBox(height: screenWidth * 0.06),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _addToCart(context, args),
                child: Text('Add to Cart', style: TextStyle(fontSize: screenWidth * 0.045)),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: screenWidth * 0.035),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            SizedBox(height: screenWidth * 0.03),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    RoutesName.reviewScreen,
                    arguments: {'productId': args['productId']},
                  );
                },
                child: Text('Write a Review', style: TextStyle(fontSize: screenWidth * 0.045)),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: screenWidth * 0.035),
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
