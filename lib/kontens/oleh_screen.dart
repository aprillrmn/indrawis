import 'package:flutter/material.dart';

class OlehOlehScreen extends StatelessWidget {
  const OlehOlehScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          automaticallyImplyLeading: true,
          iconTheme: const IconThemeData(
            color: Colors.white, // Warna ikon tombol kembali
          ),
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
            'Oleh-Oleh',
            style: TextStyle(
              color: Colors.white, // Warna teks putih
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      body: const Center(child: Text('Halaman Oleh-Oleh')),
    );
  }
}
