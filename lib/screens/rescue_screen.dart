import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RescueScreen extends StatefulWidget {
  final String alertId;

  const RescueScreen({
    super.key,
    required this.alertId,
  });

  @override
  State<RescueScreen> createState() => _RescueScreenState();
}

class _RescueScreenState extends State<RescueScreen> {
  GoogleMapController? _mapController;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Set<Marker> _markers = {};

  static const CameraPosition _initialPosition =
      CameraPosition(
    target: LatLng(
      22.5726,
      88.3639,
    ),
    zoom: 14,
  );

  @override
  void initState() {
    super.initState();
    _listenVictimLocation();
  }

  void _listenVictimLocation() {
    _firestore
        .collection('alerts')
        .doc(widget.alertId)
        .snapshots()
        .listen((doc) {
      if (!doc.exists) return;

      final data = doc.data();

      if (data == null) return;

      final lat = data["latitude"];
      final lng = data["longitude"];

      if (lat == null || lng == null) return;

      final LatLng victimPosition = LatLng(
        (lat as num).toDouble(),
        (lng as num).toDouble(),
      );

      setState(() {
        _markers = {
          Marker(
            markerId: const MarkerId("victim"),
            position: victimPosition,
            infoWindow: const InfoWindow(
              title: "Victim",
            ),
          ),
        };
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLng(victimPosition),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Rescue",
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                height: 320,
                child: GoogleMap(
                  initialCameraPosition: _initialPosition,
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                ),
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              "Rescue in Progress",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Live tracking is active.",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigation will be implemented in the next step.
                },
                icon: const Icon(Icons.navigation),
                label: const Text(
                  "Navigate",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}