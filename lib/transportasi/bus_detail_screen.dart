import 'package:flutter/material.dart';

class BusDetailScreen extends StatelessWidget {
  const BusDetailScreen({super.key});

  final List<Map<String, String>> busRoutes = const [
    {
      'jurusan': 'Indramayu – Cirebon',
      'jam': '05.00 - 20.00 WIB',
      'kelas': 'Ekonomi / AC',
    },
    {
      'jurusan': 'Indramayu – Jakarta (Kalideres)',
      'jam': '05.30 - 21.00 WIB',
      'kelas': 'Patas / AC',
    },
    {
      'jurusan': 'Indramayu – Bandung',
      'jam': '06.00 - 19.00 WIB',
      'kelas': 'Bisnis / Eksekutif',
    },
    {
      'jurusan': 'Indramayu – Bekasi',
      'jam': '05.30 - 20.00 WIB',
      'kelas': 'Ekonomi / Patas',
    },
    {
      'jurusan': 'Indramayu – Kuningan',
      'jam': '06.00 - 18.00 WIB',
      'kelas': 'Ekonomi',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF3E0), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: kToolbarHeight + 40),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Rute Bus Indramayu',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD84315),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: busRoutes.length,
                itemBuilder: (context, index) {
                  final route = busRoutes[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.directions_bus_filled,
                          color: Colors.deepOrange,
                          size: 28,
                        ),
                      ),
                      title: Text(
                        route['jurusan'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFFBF360C),
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                route['jam'] ?? '',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Kelas: ${route['kelas']}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        // Arahkan ke info detail jika ingin
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
