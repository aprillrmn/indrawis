import 'package:flutter/material.dart';

class PaketScreen extends StatelessWidget {
  const PaketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          automaticallyImplyLeading: true,
          iconTheme: const IconThemeData(
            color: Colors.white, // Tombol kembali berwarna biru
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
            'Paket Wisata',
            style: TextStyle(
              color: Colors.white, // Teks judul putih
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      body: const Center(child: Text('Halaman Paket Wisata')),
    );
  }
}
