import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  GoogleMapController? mapController;
  LatLng selectedPosition = const LatLng(
    -6.3266,
    108.32,
  ); // Titik awal Indramayu
  final TextEditingController searchController = TextEditingController();

  void _handleTap(LatLng tappedPoint) {
    setState(() {
      selectedPosition = tappedPoint;
    });
  }

  Future<void> _searchLocation() async {
    final query = searchController.text;
    if (query.isEmpty) return;

    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        final newLatLng = LatLng(loc.latitude, loc.longitude);

        setState(() {
          selectedPosition = newLatLng;
        });

        mapController?.animateCamera(CameraUpdate.newLatLngZoom(newLatLng, 15));
      } else {
        _showSnackBar("Lokasi tidak ditemukan");
      }
    } catch (e) {
      _showSnackBar("Gagal mencari lokasi");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _confirmLocation() {
    Navigator.pop(context, {
      'lat': selectedPosition.latitude,
      'lng': selectedPosition.longitude,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pilih Lokasi")),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: selectedPosition,
              zoom: 13,
            ),
            onMapCreated: (controller) {
              mapController = controller;
            },
            markers: {
              Marker(
                markerId: const MarkerId("selected"),
                position: selectedPosition,
              ),
            },
            onTap: _handleTap,
          ),
          Positioned(
            top: 15,
            left: 15,
            right: 15,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 4),
                      ],
                    ),
                    child: TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: "Cari lokasi...",
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _searchLocation(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _searchLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Icon(Icons.search, color: Colors.white),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton.icon(
              onPressed: _confirmLocation,
              icon: const Icon(Icons.check),
              label: const Text("Gunakan Lokasi Ini"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
