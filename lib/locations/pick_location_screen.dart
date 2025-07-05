import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PickLocationScreen extends StatefulWidget {
  const PickLocationScreen({super.key});

  @override
  State<PickLocationScreen> createState() => _PickLocationScreenState();
}

class _PickLocationScreenState extends State<PickLocationScreen> {
  LatLng? selectedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Lokasi'),
        backgroundColor: const Color(0xFF008170),
        actions: [
          if (selectedLocation != null)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                Navigator.pop(context, selectedLocation);
              },
            )
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(-6.200000, 106.816666), // Jakarta
          zoom: 14,
        ),
        onTap: (position) {
          setState(() {
            selectedLocation = position;
          });
        },
        markers: selectedLocation != null
            ? {
                Marker(
                  markerId: const MarkerId('selected'),
                  position: selectedLocation!,
                )
              }
            : {},
      ),
    );
  }
}
