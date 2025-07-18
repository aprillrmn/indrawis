import 'package:flutter/material.dart';

class TransportasiScreen extends StatelessWidget {
  const TransportasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          automaticallyImplyLeading: true,
          iconTheme: const IconThemeData(
            color: Color.fromARGB(255, 240, 241, 241), // Warna ikon kembali
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
            'Transportasi',
            style: TextStyle(
              color: Colors.white, // Warna teks putih
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: const Center(child: Text('Halaman Transportasi')),
    );
  }
}
