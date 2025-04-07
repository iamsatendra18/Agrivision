import 'package:flutter/material.dart';

class EsewaPaymentScreen extends StatefulWidget {
  final double totalAmount;

  const EsewaPaymentScreen({Key? key, required this.totalAmount}) : super(key: key);

  @override
  State<EsewaPaymentScreen> createState() => _EsewaPaymentScreenState();
}

class _EsewaPaymentScreenState extends State<EsewaPaymentScreen> {
  final _esewaIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();

  bool _showOtp = false;

  void _loginAndSendOtp() {
    if (_esewaIdController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnack("Please enter your eSewa ID and Password.");
      return;
    }

    setState(() {
      _showOtp = true;
    });

    _showSnack("OTP sent to your eSewa ID.");
  }

  void _confirmPayment() {
    if (_otpController.text.isEmpty) {
      _showSnack("Please enter the OTP.");
      return;
    }

    Navigator.pop(context, true); // Go back with success
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('eSewa Mobile Wallet'),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text("eSewa", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text("Total Payable: ₹${widget.totalAmount.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _esewaIdController,
                    decoration: const InputDecoration(
                      labelText: "eSewa ID",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _loginAndSendOtp,
                    child: const Text("Login & Send OTP"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                  if (_showOtp) ...[
                    const SizedBox(height: 30),
                    const Divider(),
                    const Text("OTP Verification", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Enter OTP",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _confirmPayment,
                      child: const Text("Confirm Payment"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
