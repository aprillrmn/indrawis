// import 'package:flutter/material.dart';
// import 'angkot_detail_screen.dart';

// class AngkotRoutesScreen extends StatelessWidget {
//   const AngkotRoutesScreen({super.key});

//   final List<Map<String, dynamic>> angkotRoutes = const [
//     {
//       'title': 'Trayek A - Terminal Indramayu ke Pasar Baru',
//       'description':
//           'Rute ini menghubungkan Terminal Indramayu dengan Pasar Baru.',
//       'image':
//           'https://upload.wikimedia.org/wikipedia/commons/9/9a/Angkot_MiniBus.jpg',
//       'mapUrl':
//           'https://www.google.com/maps/embed?pb=!1m28!1m12!1m3!1d7919.812317881444!2d108.31814211075612!3d-6.326168447285632!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!4m13!3e0!4m5!1s0x2e6f05840a7821fb%3A0x1e984a82dc71ac1a!2sTerminal%20Indramayu!3m2!1d-6.3271935!2d108.3238795!4m5!1s0x2e6f059c5e04206f%3A0x1d47292f4f82c41!2sPasar%20Baru%2C%20Jl.%20Siliwangi!3m2!1d-6.3229393!2d108.3241549!5e0!3m2!1sid!2sid!4v1688812345678',
//     },
//     {
//       'title': 'Trayek B - Terminal Indramayu ke Jatibarang',
//       'description': 'Rute angkot menuju arah selatan ke Jatibarang.',
//       'image':
//           'https://upload.wikimedia.org/wikipedia/commons/9/9a/Angkot_MiniBus.jpg',
//       'mapUrl':
//           'https://www.google.com/maps/embed?pb=!1m28!1m12!1m3!1d15839.888291820358!2d108.31911631856953!3d-6.342126682934021!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!4m13!3e0!4m5!1s0x2e6f05840a7821fb%3A0x1e984a82dc71ac1a!2sTerminal%20Indramayu!3m2!1d-6.3271935!2d108.3238795!4m5!1s0x2e6f04f708210b4f%3A0x2fcd42bbacc9b272!2sJatibarang!3m2!1d-6.3620559!2d108.3500937!5e0!3m2!1sid!2sid!4v1688812456789',
//     },
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Trayek Angkot Indramayu'),
//         backgroundColor: Colors.teal,
//       ),
//       body: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: angkotRoutes.length,
//         itemBuilder: (context, index) {
//           final trayek = angkotRoutes[index];
//           return Card(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             elevation: 4,
//             margin: const EdgeInsets.only(bottom: 20),
//             child: InkWell(
//               borderRadius: BorderRadius.circular(16),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => AngkotDetailScreen(trayek: trayek),
//                   ),
//                 );
//               },
//               child: Column(
//                 children: [
//                   ClipRRect(
//                     borderRadius: const BorderRadius.vertical(
//                       top: Radius.circular(16),
//                     ),
//                     child: Image.network(
//                       trayek['image'],
//                       height: 180,
//                       width: double.infinity,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           trayek['title'],
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 6),
//                         Text(
//                           trayek['description'],
//                           style: const TextStyle(color: Colors.black54),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
