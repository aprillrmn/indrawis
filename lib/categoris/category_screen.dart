import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryScreen extends StatefulWidget {
  final int kategoriId;
  final String title;

  const CategoryScreen({
    Key? key,
    required this.kategoriId,
    required this.title,
  }) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  bool _isLoading = false;
  LatLng? _currentPosition;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _determinePosition();
    await _fetchKategori();
  }

  Future<void> _determinePosition() async {
    setState(() => _isLoading = true);
    if (!await Geolocator.isLocationServiceEnabled()) {
      await Geolocator.openLocationSettings();
    }
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever) return;

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    _currentPosition = LatLng(pos.latitude, pos.longitude);
    setState(() => _isLoading = false);
  }

  Future<void> _fetchKategori() async {
    setState(() => _isLoading = true);
    try {
      final data = await Supabase.instance.client
          .from('kategori')
          .select(
            'id, nama, deskripsi, gambar_url, latitude, longitude, created_at, updated_at, kategori_grup_id',
          )
          .eq('kategori_grup_id', widget.kategoriId);

      _items = List<Map<String, dynamic>>.from(data);

      if (_currentPosition != null) {
        for (var d in _items) {
          d['distance'] = Geolocator.distanceBetween(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            (d['latitude'] ?? 0).toDouble(),
            (d['longitude'] ?? 0).toDouble(),
          );
        }
        _items.sort(
          (a, b) =>
              (a['distance'] as double).compareTo(b['distance'] as double),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat kategori: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          title: Text(
            widget.title,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          automaticallyImplyLeading: true,
          iconTheme: const IconThemeData(color: Colors.white),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F2027),
                  Color(0xFF203A43),
                  Color(0xFF2C5364),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _items.isEmpty
              ? Center(
                child: Text(
                  'Belum ada data untuk kategori ini',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _items.length,
                itemBuilder: (_, i) {
                  final d = _items[i];
                  final jarakKm =
                      d.containsKey('distance')
                          ? (d['distance'] as double) / 1000
                          : null;
                  return GestureDetector(
                    onTap:
                        () => Navigator.pushNamed(
                          context,
                          '/detail',
                          arguments: {
                            'title': d['nama'],
                            'description': d['deskripsi'],
                            'imageUrl': d['gambar_url'],
                            'latitude': d['latitude'],
                            'longitude': d['longitude'],
                            'heroTag': '',
                            'destination': d,
                            'kontenId': d['id'],
                            'destinasi': d,
                          },
                        ),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            d['gambar_url'] != null
                                ? Image.network(
                                  d['gambar_url'],
                                  width: double.infinity,
                                  height: 180,
                                  fit: BoxFit.cover,
                                )
                                : Container(
                                  height: 180,
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(Icons.image, size: 40),
                                  ),
                                ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    d['nama'] ?? '-',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  if (d['deskripsi'] != null)
                                    Text(
                                      d['deskripsi'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  if (jarakKm != null)
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          color: Colors.teal,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${jarakKm.toStringAsFixed(2)} km dari Anda',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
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

class LatLng {
  final double latitude;
  final double longitude;
  LatLng(this.latitude, this.longitude);
}
