import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang Aplikasi'),
        backgroundColor: const Color(0xFF008170),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Nama Aplikasi',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF232D3F),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Versi 1.0.0',
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 24),
              Text(
                'Aplikasi ini membantu Anda menjelajahi destinasi religi, kuliner, dan penginapan '
                'untuk memperkaya pengalaman rohani dan wisata Anda.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),
              Text(
                'Dibuat dengan ❤️ oleh Tim Developer.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
