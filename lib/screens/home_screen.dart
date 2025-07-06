import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:new_apk/admins/setting_screen.dart';
import 'package:new_apk/screens/destination_detail.dart';
import 'package:new_apk/models/edit_profile_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MyHomeScreen extends StatefulWidget {
  const MyHomeScreen({super.key});

  @override
  State<MyHomeScreen> createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {
  GoogleMapController? _googleMapController;
  LatLng? _currentPosition;
  bool _locationRequested = false;
  bool _isLoading = false;
  List<Map<String, dynamic>> _destinations = [];

  @override
  void initState() {
    super.initState();
    _fetchDestinations();
  }

  Future<void> _fetchDestinations() async {
    try {
      final response = await Supabase.instance.client
          .from('konten')
          .select('id, judul, deskripsi, gambar_url, latitude, longitude');

      setState(() {
        _destinations = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint('Error fetch destinations: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data destinasi: $e')),
      );
    }
  }

  Future<void> _determinePosition() async {
    setState(() => _isLoading = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        await Geolocator.openLocationSettings();
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = LatLng(pos.latitude, pos.longitude);
        _locationRequested = true;
      });
      _googleMapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition!, 14),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mendapatkan lokasi: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> getFilteredAndSortedDestinations() {
    final filtered = [..._destinations];
    if (_currentPosition == null) return filtered;

    for (var d in filtered) {
      d['distance'] = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        double.tryParse(d['latitude'].toString()) ?? 0.0,
        double.tryParse(d['longitude'].toString()) ?? 0.0,
      );
    }

    filtered.sort(
      (a, b) => (a['distance'] as double).compareTo(b['distance'] as double),
    );
    return filtered;
  }

  void showDetailBottomSheet(Map<String, dynamic> destination) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                destination['title'] ?? '',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(destination['description'] ?? ''),
              const SizedBox(height: 10),
              Text(
                'Lokasi: ${destination['latitude']}, ${destination['longitude']}',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed:
                    () => _openRoute(
                      LatLng(
                        double.tryParse(destination['latitude'].toString()) ??
                            0.0,
                        double.tryParse(destination['longitude'].toString()) ??
                            0.0,
                      ),
                    ),
                icon: const Icon(Icons.directions),
                label: const Text('Buka Rute di Google Maps'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openRoute(LatLng dest) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${dest.latitude},${dest.longitude}&travelmode=driving',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka Google Maps')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = getFilteredAndSortedDestinations();

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_locationRequested) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.travel_explore, size: 80, color: Colors.green),
              const SizedBox(height: 20),
              const Text(
                'Selamat Datang Sobat Indrawis',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _determinePosition,
                icon: const Icon(Icons.location_searching),
                label: const Text('Gunakan Lokasi Saya'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Destinasi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition!,
                zoom: 14,
              ),
              myLocationEnabled: true,
              markers: {
                Marker(
                  markerId: const MarkerId('current'),
                  position: _currentPosition!,
                  infoWindow: const InfoWindow(title: 'Lokasi Saya'),
                ),
                ...list.map(
                  (d) => Marker(
                    markerId: MarkerId('${d['id']}'),
                    position: LatLng(
                      double.tryParse(d['latitude'].toString()) ?? 0.0,
                      double.tryParse(d['longitude'].toString()) ?? 0.0,
                    ),
                    infoWindow: InfoWindow(
                      title: d['judul'],
                      snippet: d['deskripsi'],
                      onTap: () => showDetailBottomSheet(d),
                    ),
                    onTap: () => showDetailBottomSheet(d),
                  ),
                ),
              },
              onMapCreated: (c) => _googleMapController = c,
            ),
          ),
          Expanded(flex: 1, child: buildDestinationList(list)),
        ],
      ),
    );
  }

  Widget buildDestinationList(List<Map<String, dynamic>> list) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child:
          list.isEmpty
              ? const Center(child: Text('Belum ada destinasi'))
              : ListView.separated(
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final d = list[i];
                  final imgUrl = (d['gambar_url'] ?? '').toString();

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => DestinationDetailScreen(
                                kontenId: int.tryParse(d['id'].toString()) ?? 0,
                                heroTag: 'hero_${d['id']}',
                                title: d['judul'] ?? '',
                                description: d['deskripsi'] ?? '',
                                imageUrl: imgUrl,
                                latitude:
                                    double.tryParse(d['latitude'].toString()) ??
                                    0.0,
                                longitude:
                                    double.tryParse(
                                      d['longitude'].toString(),
                                    ) ??
                                    0.0,
                                destination: {},
                              ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child:
                                  imgUrl.isNotEmpty
                                      ? Hero(
                                        tag: 'hero_${d['id']}',
                                        child: Image.network(
                                          imgUrl,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (
                                            context,
                                            child,
                                            loadingProgress,
                                          ) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Container(
                                              width: 80,
                                              height: 80,
                                              color: Colors.grey.shade200,
                                              child: const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              ),
                                            );
                                          },
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Container(
                                              width: 80,
                                              height: 80,
                                              color: Colors.grey.shade300,
                                              child: const Icon(
                                                Icons.broken_image,
                                                size: 40,
                                                color: Colors.grey,
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                      : Container(
                                        width: 80,
                                        height: 80,
                                        color: Colors.grey.shade300,
                                        child: const Icon(
                                          Icons.image,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                                      ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    d['judul'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    d['deskripsi'] ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  if (_currentPosition != null &&
                                      d.containsKey('distance'))
                                    Text(
                                      '${(d['distance'] / 1000).toStringAsFixed(2)} km dari posisi Anda',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
