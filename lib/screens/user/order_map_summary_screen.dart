import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderMapSummaryScreen extends StatelessWidget {
  final double latitude;
  final double longitude;

  const OrderMapSummaryScreen({
    Key? key,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LatLng location = LatLng(latitude, longitude);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Delivery Location"),
        backgroundColor: Colors.green[700],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: location,
          zoom: 15,
        ),
        markers: {
          Marker(
            markerId: const MarkerId("delivery"),
            position: location,
          ),
        },
      ),
    );
  }
}
