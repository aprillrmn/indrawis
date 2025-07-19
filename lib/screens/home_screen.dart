import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:new_apk/admins/setting_screen.dart';
import 'package:new_apk/models/edit_profile_screen.dart';
import 'package:new_apk/screens/destination_detail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';

class MyHomeScreen extends StatefulWidget {
  const MyHomeScreen({super.key});

  @override
  State<MyHomeScreen> createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {
  final supabase = Supabase.instance.client;
  List<dynamic> destinasi = [];
  LatLng? userLocation;
  Set<Marker> allMarkers = {};
  GoogleMapController? mapController;
  List<dynamic> filteredDestinasi = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchDestinasi();
    getUserLocation();
  }

  Future<void> fetchDestinasi() async {
    final response = await supabase.from('konten').select();

    setState(() {
      destinasi = response;
      filteredDestinasi = response;

      allMarkers =
          response
              .where(
                (item) => item['latitude'] != null && item['longitude'] != null,
              )
              .map((item) {
                final lat = item['latitude'];
                final lng = item['longitude'];

                final latitude =
                    lat is double ? lat : double.tryParse(lat.toString());
                final longitude =
                    lng is double ? lng : double.tryParse(lng.toString());

                if (latitude == null || longitude == null) return null;

                return Marker(
                  markerId: MarkerId(item['judul']),
                  position: LatLng(latitude, longitude),
                  infoWindow: InfoWindow(title: item['judul']),
                );
              })
              .whereType<Marker>()
              .toSet();
    });
  }

  Future<void> getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always)
        return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      userLocation = LatLng(position.latitude, position.longitude);
    });
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.0174533;
    final a =
        0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  void filterDestinasi(String query) {
    setState(() {
      filteredDestinasi =
          destinasi.where((item) {
            final title = item['judul'].toString().toLowerCase();
            return title.contains(query.toLowerCase());
          }).toList();
    });
  }

  Widget buildMenuIcon(IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        // Navigasi berdasarkan label menu
        Navigator.pushNamed(context, '/${label.toLowerCase()}');
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.blue.shade900),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget buildDestinasiCard(dynamic data) {
    double? distance;
    if (userLocation != null &&
        data['latitude'] != null &&
        data['longitude'] != null) {
      distance = calculateDistance(
        userLocation!.latitude,
        userLocation!.longitude,
        data['latitude'],
        data['longitude'],
      );
    }

    return GestureDetector(
      onTap: () {
        print('title: $data.judul ');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => DestinationDetailScreen(
                  kontenId: data['id'].toString(),
                  title: data['judul'],
                  description: data['deskripsi'],
                  imageUrl: data['gambar_url'],
                  latitude: data['latitude'],
                  longitude: data['longitude'],
                  destination: data,
                  heroTag: data['id'].toString(),
                  destinasi: data,
                  location: data['lokasi'] as String,
                ),
          ),
        );
      },
      child: SizedBox(
        width: 160,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Image.network(
                  data['gambar_url'],
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['judul'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (distance != null)
                      Text(
                        '${distance.toStringAsFixed(2)} km dari lokasi Anda',
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child:
            userLocation == null
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Container(
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
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        height: 80,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: AssetImage(
                                        'assets/images/awal.png',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Indramayu',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      'Wisata',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.settings,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => SettingsScreen(),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.account_circle,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => EditProfileScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Google Map
                      SizedBox(
                        height: 160,
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: userLocation!,
                            zoom: 14,
                          ),
                          markers: {
                            Marker(
                              markerId: const MarkerId('userLocation'),
                              position: userLocation!,
                              infoWindow: const InfoWindow(
                                title: 'Lokasi Anda',
                              ),
                            ),
                            ...allMarkers, // ← Tambahkan semua marker destinasi
                          },
                          onMapCreated: (controller) {
                            mapController = controller;
                          },
                        ),
                      ),

                      // Search Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: 'Cari destinasi...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged: filterDestinasi,
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Menu Grid
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SizedBox(
                          height: 150,
                          child: GridView.count(
                            crossAxisCount: 4,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            childAspectRatio: 1,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            children: [
                              buildMenuIcon(Icons.place, 'Religi'),
                              buildMenuIcon(Icons.event, 'Aktivitas'),
                              buildMenuIcon(Icons.hotel, 'Akomodasi'),
                              buildMenuIcon(Icons.restaurant, 'Kuliner'),
                              buildMenuIcon(
                                Icons.directions_car,
                                'Transportasi',
                              ),
                              buildMenuIcon(Icons.shopping_cart, 'Oleh-oleh'),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Rekomendasi Header
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text(
                          'Rekomendasi Destinasi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Rekomendasi List
                      SizedBox(
                        height: 170,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: filteredDestinasi.length,
                            separatorBuilder:
                                (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              return buildDestinasiCard(
                                filteredDestinasi[index],
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
      ),
    );
  }
}
