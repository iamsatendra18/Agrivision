import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewScreen extends StatefulWidget {
  final String productId;

  const ReviewScreen({required this.productId});

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reviewController = TextEditingController();
  int _rating = 0;
  bool _isSubmitting = false;

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate() || _rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please add review & rating"),
      ));
      return;
    }

    setState(() => _isSubmitting = true);

    final user = FirebaseAuth.instance.currentUser;
    final reviewData = {
      'productId': widget.productId,
      'userId': user?.uid,
      'reviewText': _reviewController.text.trim(),
      'rating': _rating,
      'timestamp': Timestamp.now(),
    };

    try {
      await FirebaseFirestore.instance.collection('reviews').add(reviewData);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("✅ Review submitted!")));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Error: $e")));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < _rating ? Icons.star : Icons.star_border,
            color: Colors.orange,
          ),
          onPressed: () => setState(() => _rating = index + 1),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Write a Review"), backgroundColor: Colors.green[700]),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text("Rate the product", style: TextStyle(fontSize: 18)),
              SizedBox(height: 8),
              _buildStarRating(),
              SizedBox(height: 20),
              TextFormField(
                controller: _reviewController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: "Write your review...",
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? "Review is required" : null,
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitReview,
                icon: Icon(Icons.send),
                label: Text("Submit Review"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
