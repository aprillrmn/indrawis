import 'package:flutter/material.dart';
import 'package:new_apk/models/coment_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';

class DestinationDetailScreen extends StatefulWidget {
  final String kontenId;
  final String title;
  final String description;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final String location;

  const DestinationDetailScreen({
    Key? key,
    required this.kontenId,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required Map destination,
    required String heroTag,
    required destinasi,
    required this.location,
  }) : super(key: key);

  @override
  State<DestinationDetailScreen> createState() =>
      _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  final supabase = Supabase.instance.client;
  final TextEditingController _commentController = TextEditingController();
  List<Map<String, dynamic>> nearbyPlaces = [];
  bool isLoading = true;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

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
      debugPrint('Error fetching nearby places: $e');
      setState(() => isLoading = false);
    }
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371;
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

  void _showPlaceDetail(Map<String, dynamic> place) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (place['gambar_url'] != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      place['gambar_url'],
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 16),
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
                  onPressed: () async {
                    _handleOpenMaps();
                  },
                  icon: const Icon(Icons.directions),
                  label: const Text('Buka di Google Maps'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleOpenMaps() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      final wantLogin = await showDialog<bool>(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('Login Diperlukan'),
              content: const Text(
                'Anda perlu login untuk mencatat kunjungan. Mau login sekarang?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Tidak'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Ya'),
                ),
              ],
            ),
      );
      if (wantLogin == true) {
        final result = await Navigator.pushNamed(context, '/login');
        if (result != true) return;
      } else {
        return;
      }
    }

    final now = DateTime.now();
    await supabase.from('aktivitas').insert({
      'user_id': supabase.auth.currentUser!.id,
      'note': widget.title,
      'location': widget.location,
      'tanggal': now.toIso8601String().split('T').first,
      'visited_at': now.toIso8601String(),
    });

    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${widget.latitude},${widget.longitude}&travelmode=driving',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membuka Google Maps')),
      );
    }
  }

  Future<List<CommentModel>> fetchKomentar() async {
    final response = await supabase
        .from('komentar')
        .select('id, nama, isi, tanggal, foto')
        .eq('konten_id', widget.kontenId)
        .order('tanggal', ascending: false);
    return (response as List)
        .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> submitComment() async {
    final isiKomentar = _commentController.text.trim();
    if (isiKomentar.isEmpty) return;

    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final profile =
        await supabase
            .from('profiles')
            .select('nama, foto_url')
            .eq('id', userId)
            .single();

    final nama = profile['nama'] ?? 'Anonim';
    final foto = profile['foto_url'] ?? '';

    try {
      await supabase.from('komentar').insert({
        'nama': nama,
        'isi': isiKomentar,
        'tanggal': DateTime.now().toIso8601String(),
        'foto': foto,
        'konten_id': widget.kontenId,
      });

      _commentController.clear();
      setState(() {});
    } catch (e) {
      print('Gagal mengirim komentar: $e');
    }
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
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, controller) {
            Future<List<CommentModel>> futureKomentar = fetchKomentar();
            return Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  "Komentar",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: FutureBuilder<List<CommentModel>>(
                    future: futureKomentar,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      }
                      final komentarList = snapshot.data ?? [];
                      if (komentarList.isEmpty) {
                        return const Center(child: Text("Belum ada komentar."));
                      }
                      return ListView.builder(
                        controller: controller,
                        itemCount: komentarList.length,
                        itemBuilder: (_, index) {
                          final komentar = komentarList[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                komentar.foto.isNotEmpty
                                    ? Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.grey[200],
                                        image: DecorationImage(
                                          image: NetworkImage(komentar.foto),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                                    : Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.grey[300],
                                      ),
                                      child: const Icon(Icons.person),
                                    ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        komentar.nama,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(komentar.isi),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${komentar.tanggal.toLocal()}"
                                            .split('.')
                                            .first,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: "Tambahkan komentar...",
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: submitComment,
                      ),
                    ],
                  ),
                ),
              ],
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
              TextButton.icon(
                onPressed: () async {
                  final user = supabase.auth.currentUser;
                  if (user == null) {
                    final result = await showDialog<bool>(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Login Diperlukan'),
                            content: const Text(
                              'Anda perlu login terlebih dahulu untuk memberikan komentar. Ingin login sekarang?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Tidak'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Ya'),
                              ),
                            ],
                          ),
                    );

                    // Jika pengguna memilih "Ya", navigasi ke login dan tunggu hasilnya
                    if (result == true) {
                      final loggedIn = await Navigator.pushNamed(
                        context,
                        '/login',
                      );

                      // Jika berhasil login, tampilkan modal komentar
                      if (loggedIn == true) {
                        _showCommentsModal();
                      }
                    }
                  } else {
                    _showCommentsModal();
                  }
                },
                icon: const Icon(
                  Icons.comment,
                  color: Color.fromARGB(255, 0, 0, 0),
                  size: 24,
                ),
                label: const Text(
                  'Komentar',
                  style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
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
                      onPressed: _handleOpenMaps,
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
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: nearbyPlaces.length,
                          itemBuilder: (context, index) {
                            final place = nearbyPlaces[index];
                            return GestureDetector(
                              onTap: () => _showPlaceDetail(place),
                              child: Container(
                                width: 140,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.grey[200],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                      child: Image.network(
                                        place['gambar_url'] ?? '',
                                        height: 90,
                                        width: 140,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                                  height: 90,
                                                  color: Colors.grey,
                                                  child: const Icon(
                                                    Icons.broken_image,
                                                  ),
                                                ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Text(
                                        place['judul'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
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
