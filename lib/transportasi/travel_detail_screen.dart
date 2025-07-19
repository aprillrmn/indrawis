import 'package:flutter/material.dart';

class TravelDetailScreen extends StatelessWidget {
  const TravelDetailScreen({super.key});

  final List<Map<String, String>> travelList = const [
    {
      'tujuan': 'Indramayu – Bandung',
      'jadwal': '08.00, 13.00, 17.00 WIB',
      'layanan': 'Door to Door / AC',
    },
    {
      'tujuan': 'Indramayu – Jakarta (Bandara Soekarno Hatta)',
      'jadwal': '06.00, 12.00, 18.00 WIB',
      'layanan': 'Bandara / Eksekutif',
    },
    {
      'tujuan': 'Indramayu – Bekasi',
      'jadwal': '07.00, 14.00, 19.00 WIB',
      'layanan': 'Pool to Pool / Ekonomi',
    },
    {
      'tujuan': 'Indramayu – Depok',
      'jadwal': '06.30, 12.30, 17.30 WIB',
      'layanan': 'Door to Door / AC',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8F5E9), Color(0xFFFFFFFF)],
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
                'Jasa Travel Indramayu',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: travelList.length,
                itemBuilder: (context, index) {
                  final travel = travelList[index];
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
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.airport_shuttle_rounded,
                          color: Colors.green,
                          size: 28,
                        ),
                      ),
                      title: Text(
                        travel['tujuan'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.schedule,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                travel['jadwal'] ?? '',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Layanan: ${travel['layanan']}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        // Tambahkan detail travel atau navigasi
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
