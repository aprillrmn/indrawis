import 'package:flutter/material.dart';

class AngkotListScreen extends StatelessWidget {
  final List<Map<String, String>> trayekList = [
    {
      'kode': 'Angkot 01',
      'rute':
          'Terminal Kota – Sudirman - Panjaitan - Suprapto - Tanjung Pura - Olahraga - Gatot Subroto (Bunderan Kijang) - Singaraja - Kec. Balongan - Wismajati - Balongan - Tegalurung - Singaraja - Sudirman - Terminal (PP)',
      'jam': '05.00 - 16.00 WIB',
    },
    {
      'kode': 'Angkot 02',
      'rute':
          'Terminal – Gatot Subroto - Suprapto - Ahmad Yani - Kartini - S. Parman - Siliwangi - Yos Sudarso - Sudirman - Terminal (PP)',
      'jam': '05.00 - 16.00 WIB',
    },
    {
      'kode': 'Angkot 03',
      'rute':
          'Terminal Kota – Sudirman - Yos Sudarso - Siliwangi - M.T Haryono - Gatot Subroto - Sudirman - Terminal (PP)',
      'jam': '05.00 - 16.00 WIB',
    },
    {
      'kode': 'Angkot 04',
      'rute':
          'Terminal Kota – Sudirman - Tanjung Pura - Suprapto - Gatot Subroto - M.T Haryono - Perjuangan - Suprapto - Cimanuk - Bima Basuki - Panjaitan - Terminal (PP)',
      'jam': '05.00 - 16.00 WIB',
    },
    {
      'kode': 'Angkot 05',
      'rute':
          'Terminal – Gatot Subroto - Pasar Baru - Pasarean - Suprapto - Cimanuk - S. Parman - Yos Sudarso - Karangsong - Pahlawan - Terminal (PP)',
      'jam': '05.00 - 16.00 WIB',
    },
  ];

  AngkotListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
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
                'Rute Angkot Indramayu',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 251, 252, 252),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: trayekList.length,
                itemBuilder: (context, index) {
                  final trayek = trayekList[index];
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
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.directions_bus,
                          color: Colors.teal,
                          size: 28,
                        ),
                      ),
                      title: Text(
                        trayek['kode'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF004D40),
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Text(
                            trayek['rute'] ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
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
                                trayek['jam'] ?? '',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      onTap: () {
                        // Bisa diarahkan ke detail jika ingin
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
