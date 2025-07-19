import 'package:flutter/material.dart';
import 'package:new_apk/transportasi/angkot_detail_screen.dart';
import 'package:new_apk/transportasi/bus_detail_screen.dart';
import 'package:new_apk/transportasi/travel_detail_screen.dart';

class TransportasiScreen extends StatelessWidget {
  const TransportasiScreen({super.key});

  final List<Map<String, dynamic>> transportasiList = const [
    {
      'title': 'Angkot',
      'description':
          'Angkutan kota dalam wilayah Indramayu. Cocok untuk perjalanan jarak pendek.',
      'icon': Icons.directions_car,
      'color': Color(0xFFE3F2FD),
    },
    {
      'title': 'Bus',
      'description': 'Bus antar kota dan provinsi yang melintasi Indramayu.',
      'icon': Icons.directions_bus,
      'color': Color(0xFFFFF3E0),
    },
    {
      'title': 'Travel',
      'description':
          'Layanan travel door-to-door menuju kota besar seperti Bandung, Jakarta.',
      'icon': Icons.airport_shuttle,
      'color': Color(0xFFE8F5E9),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
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
          title: const Text(
            'Transportasi',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: transportasiList.length,
        itemBuilder: (context, index) {
          final item = transportasiList[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 10),
            color: item['color'],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: InkWell(
              onTap: () {
                Widget page;

                // Ganti dengan widget yang sesuai
                if (item['title'] == 'Angkot') {
                  page = AngkotListScreen();
                } else if (item['title'] == 'Bus') {
                  page = const BusDetailScreen();
                } else {
                  page = const TravelDetailScreen();
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => page),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        item['icon'],
                        size: 28,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item['description'],
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
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
        },
      ),
    );
  }
}
