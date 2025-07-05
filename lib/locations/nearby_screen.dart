import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:new_apk/services/konten.dart';
import 'package:new_apk/services/konten_service.dart';

class NearbyScreen extends StatefulWidget {
  const NearbyScreen({super.key});

  @override
  State<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen> {
  final KontenService _kontenService = KontenService();

  List<Konten> _kontenList = [];
  bool _isLoading = true;

  final LatLng _userLatLng = LatLng(-6.3275, 108.32); // Indramayu

  @override
  void initState() {
    super.initState();
    _loadNearbyKonten();
  }

  Future<void> _loadNearbyKonten() async {
    try {
      final konten = await _kontenService.getNearbyKonten(
        latitude: _userLatLng.latitude,
        longitude: _userLatLng.longitude,
        limit: 15,
      );
      setState(() {
        _kontenList = konten;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
      }
    }
  }

  void _showKontenDetail(Konten konten) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  konten.judul,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (konten.deskripsi != null && konten.deskripsi!.isNotEmpty)
                  Text(konten.deskripsi!, style: const TextStyle(fontSize: 14)),
                if (konten.lokasi != null && konten.lokasi!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(child: Text(konten.lokasi!)),
                      ],
                    ),
                  ),
                if (konten.distance != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Jarak: ${konten.distance!.toStringAsFixed(2)} km',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Destinasi Terdekat')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : FlutterMap(
                options: MapOptions(center: _userLatLng, zoom: 12),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _userLatLng,
                        width: 40,
                        height: 40,
                        // alignment: Alignment.center,
                        builder:
                            (_) => const Icon(
                              Icons.person_pin_circle,
                              size: 40,
                              color: Colors.blue,
                            ),
                      ),
                      ..._kontenList.map((konten) {
                        final lat = konten.latitude ?? 0;
                        final lon = konten.longitude ?? 0;
                        return Marker(
                          point: LatLng(lat, lon),
                          width: 40,
                          height: 40,
                          // alignment: Alignment.center,
                          builder:
                              (_) => GestureDetector(
                                onTap: () => _showKontenDetail(konten),
                                child: const Icon(
                                  Icons.location_on,
                                  size: 40,
                                  color: Colors.red,
                                ),
                              ),
                        );
                      }).toList(),
                    ],
                  ),
                ],
              ),
    );
  }
}
