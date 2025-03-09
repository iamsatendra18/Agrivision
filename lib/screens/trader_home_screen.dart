import 'package:flutter/material.dart';

class TraderHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Trader Dashboard")),
      body: Center(
        child: Text("Welcome, Trader!", style: TextStyle(fontSize: 22)),
      ),
    );
  }
}
