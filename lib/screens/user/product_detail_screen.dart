import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productName;
  final String productImage;
  final String productDescription;
  final double productPrice;
  final double productQuantity;

  ProductDetailScreen({
    required this.productName,
    required this.productImage,
    required this.productDescription,
    required this.productPrice,
    required this.productQuantity,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(productName),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(productImage),
              SizedBox(height: 16.0),
              Text(
                productName,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Text(
                'Rs.${productPrice.toStringAsFixed(2)} per KG',
                style: TextStyle(fontSize: 20, color: Colors.green),
              ),
              SizedBox(height: 8.0),
              Text(
                '${productQuantity.toStringAsFixed(2)} Kg available',
                style: TextStyle(fontSize: 20, color: Colors.green),
              ),
              SizedBox(height: 16.0),
              Text(
                productDescription,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  // Add to cart functionality
                },
                child: Text('Add to Cart'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}