import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  double _opacity = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _opacity = 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text('Tentang Aplikasi'),
        backgroundColor: const Color(0xFF008170),
        elevation: 2,
      ),
      body: SafeArea(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(seconds: 1),
          curve: Curves.easeIn,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Column(
                  children: [
                    Image.asset('assets/images/awal.png', height: 120),
                    const Text(
                      'Indramayu Wisata',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF232D3F),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Versi 1.0.0 (Beta)',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Tentang Aplikasi',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF008170),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Indramayu Wisata (Indrawis) adalah aplikasi panduan wisata '
                        'untuk membantu Anda menjelajahi destinasi religi, kuliner, '
                        'dan penginapan terbaik di Indramayu. Temukan pengalaman '
                        'wisata yang berkesan langsung dari genggaman Anda.',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informasi',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF008170),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Icons.email, color: Color(0xFF008170)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: _launchEmail,
                              child: const Text(
                                'apriliadyrahman9@gmail.com',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF008170),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.instagram,
                            color: Color(0xFF008170),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: _launchInstagram,
                              child: const Text(
                                '@dispara_indramayu',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF008170),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: const [
                      Icon(Icons.copyright, color: Colors.grey, size: 28),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          '© 2025 Aprillrmn-D3TI.3A. \n Semua hak dilindungi.',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'apriliadyrahman9@gmail.com',
    );

    if (!await launchUrl(emailUri, mode: LaunchMode.externalApplication)) {
      throw Exception('Tidak bisa membuka email');
    }
  }

  Future<void> _launchInstagram() async {
    final Uri instagramUri = Uri.parse(
      'https://instagram.com/dispara_indramayu',
    );

    if (!await launchUrl(instagramUri, mode: LaunchMode.externalApplication)) {
      throw Exception('Tidak bisa membuka Instagram');
    }
  }
}
