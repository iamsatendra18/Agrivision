import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

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
                child: Image.asset(args['productImage'], height: 200),
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Add to cart functionality
                  },
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
            ],
          ),
        ),
      ),
    );
  }
}
