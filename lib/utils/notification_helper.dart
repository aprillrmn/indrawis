// import 'package:flutter/material.dart';

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await initializeNotifications();
//   runApp(const MyApp());
// }

// Future<void> initializeNotifications() async {
//   const AndroidInitializationSettings initializationSettingsAndroid =
//       AndroidInitializationSettings('@mipmap/ic_launcher');

//   const InitializationSettings initializationSettings = InitializationSettings(
//     android: initializationSettingsAndroid,
//   );

//   await flutterLocalNotificationsPlugin.initialize(initializationSettings);
// }

// Future<void> showRecommendationNotification({
//   required String title,
//   required String body,
// }) async {
//   const AndroidNotificationDetails androidPlatformChannelSpecifics =
//       AndroidNotificationDetails(
//     'wisata_rekomendasi_channel',
//     'Rekomendasi Wisata',
//     channelDescription: 'Channel untuk rekomendasi kunjungan wisata',
//     importance: Importance.max,
//     priority: Priority.high,
//     ticker: 'ticker',
//   );

//   const NotificationDetails platformChannelSpecifics =
//       NotificationDetails(android: androidPlatformChannelSpecifics);

//   await flutterLocalNotificationsPlugin.show(
//     0,
//     title,
//     body,
//     platformChannelSpecifics,
//     payload: 'rekomendasi',
//   );
// }

// void showFlushbar(BuildContext context, String message) {
//   Flushbar(
//     message: message,
//     duration: const Duration(seconds: 3),
//     backgroundColor: Colors.teal.shade700,
//     flushbarPosition: FlushbarPosition.TOP,
//     margin: const EdgeInsets.all(8),
//     borderRadius: BorderRadius.circular(12),
//     icon: const Icon(
//       Icons.check_circle,
//       color: Colors.white,
//     ),
//   ).show(context);
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Demo Notifikasi',
//       theme: ThemeData(
//         primarySwatch: Colors.teal,
//       ),
//       home: const HomeScreen(),
//     );
//   }
// }

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Notifikasi Demo')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: () {
//                 showRecommendationNotification(
//                   title: 'Ada tempat wisata baru!',
//                   body: 'Yuk kunjungi Pantai Pasir Putih.',
//                 );
//               },
//               child: const Text('Tampilkan Local Notification'),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 showFlushbar(
//                     context, 'Data berhasil disimpan ke database!');
//               },
//               child: const Text('Tampilkan Flushbar'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
