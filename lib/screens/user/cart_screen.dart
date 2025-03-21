import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Order History'),
        backgroundColor: Colors.green[700], // Agriculture theme
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/agrivision_logo.png'),
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              // Section 1: Pending Orders
              _buildOrderSection(
                title: "🟡 Pending Orders",
                orders: [
                  {"name": "Organic Tomatoes", "date": "March 12, 2025, 10:30 AM"},
                  {"name": "Golden Potatoes", "date": "March 13, 2025, 11:15 AM"},
                ],
                onTap: (order) => _showPendingOrderDetails(context, order),
              ),

              // Section 2: Delivered Orders
              _buildOrderSection(
                title: "✅ Delivered Orders",
                orders: [
                  {"name": "Fresh Spinach", "date": "March 10, 2025, 3:00 PM"},
                ],
              ),

              // Section 3: Canceled Orders
              _buildOrderSection(
                title: "❌ Canceled Orders",
                orders: [
                  {"name": "Sunflower Seeds", "date": "March 8, 2025, 5:20 PM"},
                ],
              ),

              const SizedBox(height: 20),

              // Order Now Button
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to Product Ordering Page
                  },
                  icon: const Icon(Icons.shopping_cart_checkout, color: Colors.white),
                  label: const Text('Order Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // Widget to build order history sections
  Widget _buildOrderSection({required String title, required List<Map<String, String>> orders, Function(Map<String, String>)? onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.brown[700]),
        ),
        const SizedBox(height: 5),
        orders.isEmpty
            ? const Text("No orders found", style: TextStyle(fontSize: 16, color: Colors.brown))
            : Column(
          children: orders.map((order) {
            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                title: Text(order["name"]!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                subtitle: Text("Ordered on: ${order["date"]}", style: const TextStyle(fontSize: 16, color: Colors.black54)),
                trailing: onTap != null
                    ? IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.green),
                  onPressed: () => onTap(order),
                )
                    : null,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  // Function to show pending order details
  void _showPendingOrderDetails(BuildContext context, Map<String, String> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "🟡 Pending Order Details",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.brown[700]),
              ),
              const SizedBox(height: 10),

              ListTile(
                title: Text(order["name"]!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                subtitle: Text("Price: ₹40 | Quantity: 2", style: const TextStyle(fontSize: 16, color: Colors.black54)),
              ),
              const Divider(),

              // Subtotal and Charges
              ListTile(
                title: const Text("Subtotal"),
                trailing: const Text("₹80"),
              ),
              ListTile(
                title: const Text("Delivery Charge"),
                trailing: const Text("₹20"),
              ),
              ListTile(
                title: const Text("Total Amount"),
                trailing: const Text("₹100", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
              ),

              // Order Note & Shipping
              const SizedBox(height: 10),
              const Text("Order Note: Please deliver fresh items.", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 5),
              const Text("Shipping To: Village Road, Agri Farm, Kalaiya Nepal", style: TextStyle(fontSize: 16)),

              const SizedBox(height: 20),

              // Buttons: Need Help & Cancel Order
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      _showNeedHelpPopup(context);
                    },
                    child: const Text("Need Help?", style: TextStyle(color: Colors.blue, fontSize: 16)),
                  ),
                  TextButton(
                    onPressed: () {
                      _showCancelConfirmation(context);
                    },
                    child: const Text("Cancel Order", style: TextStyle(color: Colors.red, fontSize: 16)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to show need help popup
  void _showNeedHelpPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Need Help!"),
          content: const Text(
            "For assistance, please contact our support at:\nstandrakushwaha2021@gmail.com",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // Function to show cancel order confirmation
  void _showCancelConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Cancel Order"),
          content: const Text("Are you sure you want to cancel the product?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Remove order logic
              },
              child: const Text("Yes, Cancel", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
