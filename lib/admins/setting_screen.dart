import 'package:flutter/material.dart';
import 'package:new_apk/admins/ChangePasswordScreen.dart';
import 'package:new_apk/services/auth_service.dart';
import 'package:new_apk/screens/login_screen.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    const mainColor = Color(0xFF008170);
    const textColor = Color(0xFF232D3F);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Akun',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),
              _buildCardTile(
                icon: Icons.lock_outline,
                text: 'Ubah Kata Sandi',
                iconColor: mainColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChangePasswordScreen(),
                    ),
                  );
                },
              ),
              _buildCardTile(
                icon: Icons.logout,
                text: 'Keluar',
                iconColor: Colors.red,
                onTap: () => _showLogoutDialog(context),
              ),
              const SizedBox(height: 32),
              const Text(
                'Aplikasi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),
              _buildCardTile(
                icon: Icons.info_outline,
                text: 'Tentang Aplikasi',
                iconColor: mainColor,
                onTap: () => Navigator.pushNamed(context, '/about'),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SwitchListTile(
                  title: const Text('Mode Gelap'),
                  secondary: const Icon(Icons.dark_mode),
                  value: themeProvider.isDarkMode,
                  activeColor: mainColor,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardTile({
    required IconData icon,
    required String text,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(text),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi Keluar'),
            content: const Text('Apakah Anda yakin ingin keluar?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(); 
                  final navigator = Navigator.of(context);

                  await authService.logout();

                  if (!mounted) return;

                  navigator.pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                child: const Text('Ya'),
              ),
            ],
          ),
    );
  }
}
