import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';

class DestinationDetailScreen extends StatefulWidget {
  final String title;
  final String description;
  final String imageUrl;
  final double latitude;
  final double longitude;

  const DestinationDetailScreen({
    Key? key,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required Map<String, dynamic> destination,
    required kontenId,
    required String heroTag,
  }) : super(key: key);

  @override
  State<DestinationDetailScreen> createState() =>
      _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  List<Map<String, dynamic>> komentarList = [];
  bool isLoadingKomentar = false;
  final TextEditingController komentarController = TextEditingController();

  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> nearbyPlaces = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNearbyPlaces();
  }

  Future<void> fetchNearbyPlaces() async {
    try {
      final data = await supabase
          .from('konten')
          .select('id, judul, deskripsi, gambar_url, latitude, longitude');

      const radiusKm = 5;
      final filtered =
          data.where((place) {
            final lat = (place['latitude'] as num?)?.toDouble() ?? 0.0;
            final lng = (place['longitude'] as num?)?.toDouble() ?? 0.0;
            final distance = _calculateDistance(
              widget.latitude,
              widget.longitude,
              lat,
              lng,
            );
            return distance <= radiusKm;
          }).toList();

      setState(() {
        nearbyPlaces = filtered.cast<Map<String, dynamic>>();
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching places: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371; // km
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degToRad(double deg) => deg * (pi / 180);

  Future<void> _openInMaps({double? lat, double? lng}) async {
    final destLat = lat ?? widget.latitude;
    final destLng = lng ?? widget.longitude;
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$destLat,$destLng&travelmode=driving',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membuka Google Maps')),
      );
    }
  }

  void _showPlaceDetail(Map<String, dynamic> place) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                place['judul'] ?? '',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                place['deskripsi'] ?? '',
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _openInMaps(
                    lat: (place['latitude'] as num?)?.toDouble(),
                    lng: (place['longitude'] as num?)?.toDouble(),
                  );
                },
                icon: const Icon(Icons.map),
                label: const Text('Buka di Google Maps'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCommentsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Text(
                    "Komentar",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      controller: controller,
                      itemCount: 10, // dummy dulu
                      itemBuilder:
                          (_, index) => ListTile(
                            title: Text("Pengguna ${index + 1}"),
                            subtitle: Text(
                              "Ini komentar ke-${index + 1} tentang tempat ini.",
                            ),
                          ),
                    ),
                  ),
                  const Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Tambahkan komentar...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // nanti tambahkan fungsi kirim komentar
                        },
                        icon: const Icon(Icons.send),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: theme.primaryColor,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.network(
                widget.imageUrl,
                height: 240,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return SizedBox(
                    height: 240,
                    child: Center(
                      child: CircularProgressIndicator(
                        value:
                            loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes ?? 1)
                                : null,
                      ),
                    ),
                  );
                },
                errorBuilder:
                    (context, error, stackTrace) => const SizedBox(
                      height: 240,
                      child: Center(child: Icon(Icons.broken_image, size: 48)),
                    ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _showCommentsModal,
                      icon: const Icon(
                        Icons.comment,
                        color: Colors.grey,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(widget.description, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _openInMaps(),
                      icon: const Icon(Icons.directions),
                      label: const Text('Buka di Google Maps'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Rekomendasi di sekitar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (nearbyPlaces.isEmpty)
                      const Text('Tidak ada rekomendasi di sekitar.')
                    else
                      SizedBox(
                        height: 160,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: nearbyPlaces.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final place = nearbyPlaces[index];
                            return GestureDetector(
                              onTap: () => _showPlaceDetail(place),
                              child: Container(
                                width: 200,
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.blueAccent,
                                    width: 1,
                                  ),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (place['gambar_url'] != null)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          place['gambar_url'],
                                          height: 80,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    const SizedBox(height: 8),
                                    Text(
                                      place['judul'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      place['deskripsi'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
