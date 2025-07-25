import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:new_apk/kontens/kuliner_screen.dart';
import 'package:new_apk/kontens/penginapan_screen.dart';
import 'package:new_apk/kontens/religi_screen.dart';
import 'package:new_apk/kontens/aktivitas_screen.dart';
import 'package:new_apk/kontens/oleh_screen.dart';
import 'package:new_apk/kontens/transportasi_screen.dart';
import 'package:new_apk/screens/destination_detail.dart';
import 'package:new_apk/screens/home_screen.dart';
import 'package:new_apk/screens/intro_screen.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:new_apk/providers/theme_provider.dart';
import 'package:new_apk/screens/splash_screen.dart';
import 'package:new_apk/screens/login_screen.dart';
import 'package:new_apk/screens/register_screen.dart';
import 'package:new_apk/models/edit_profile_screen.dart';
import 'package:new_apk/screens/logo_screen.dart';

import 'package:new_apk/admins/admin_home_screen.dart';
import 'package:new_apk/admins/manage_destinations_screen.dart';
import 'package:new_apk/admins/manage_users_screen.dart';
import 'package:new_apk/admins/manage_comments_screen.dart';
import 'package:new_apk/admins/setting_screen.dart';
import 'package:new_apk/admins/AboutScreen.dart';
import 'package:new_apk/admins/ChangePasswordScreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID', null);

  await Supabase.initialize(
    url: 'https://qfkkurgzfspapoufusdd.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFma2t1cmd6ZnNwYXBvdWZ1c2RkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTExMDM4MzUsImV4cCI6MjA2NjY3OTgzNX0.j3rztQSl9oOsz0irQhqIBgdFNRw7yt0KLFnmy1pmRy4',
  );

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ThemeProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Wisata Religi',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.teal,
        primaryColor: const Color(0xFF005B41),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        fontFamily: 'Poppins',
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF005B41)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF005B41),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.teal,
        fontFamily: 'Poppins',
      ),

      // ROUTES
      initialRoute: '/',
      routes: {
        '/': (_) => const LogoScreen(),
        '/splash': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => MyHomeScreen(),
        '/profile': (_) => const EditProfileScreen(),
        '/intro': (_) => const IntroScreen(),

        // Admin
        '/admin': (_) => const AdminHomeScreen(),
        '/admin/manage-destinations': (_) => const ManageDestinationsScreen(),
        '/admin/manage-users': (_) => const ManageCategoriesScreen(),
        '/admin/manage-comments': (_) => const ManageCommentsScreen(),

        // Settings
        '/settings': (_) => SettingsScreen(),
        '/change-password': (_) => const ChangePasswordScreen(),
        '/about': (_) => const AboutScreen(),

        // Route untuk masing-masing kategori
        '/religi': (context) => const ReligiScreen(),
        '/kuliner': (context) => const KulinerScreen(),
        '/penginapan': (context) => const PenginapanScreen(),

        '/amazing': (_) => const ReligiScreen(),
        '/aktivitas': (_) => const AktivitasScreen(),
        '/akomodasi': (_) => const PenginapanScreen(),
        '/restoran': (_) => const KulinerScreen(),
        '/transportasi': (_) => const TransportasiScreen(),
        '/oleh-oleh': (_) => const OlehOlehScreen(),
      },

      onGenerateRoute: (settings) {
        if (settings.name == '/detail') {
          final args = settings.arguments;

          if (args is Map<String, dynamic>) {
            return MaterialPageRoute(
              builder:
                  (_) => DestinationDetailScreen(
                    title: args['title']?.toString() ?? 'Judul Tidak Ditemukan',
                    description: args['description']?.toString() ?? '',
                    imageUrl: args['imageUrl']?.toString() ?? '',
                    latitude: (args['latitude'] ?? 0.0).toDouble(),
                    longitude: (args['longitude'] ?? 0.0).toDouble(),
                    kontenId: (args['kontenId'] ?? 0).toString(),
                    destination: args['destination'] ?? {},
                    heroTag: args['heroTag'] ?? '',
                    destinasi: args['destinasi'],
                    location: '',
                  ),
            );
          } else {
            return MaterialPageRoute(
              builder:
                  (_) => Scaffold(
                    appBar: AppBar(title: const Text("Error")),
                    body: const Center(child: Text("Argument tidak valid")),
                  ),
            );
          }
        }

        return null;
      },
    );
  }
}
