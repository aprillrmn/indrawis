import 'package:flutter/material.dart';
import 'package:new_apk/categoris/category_screen.dart';

class ReligiScreen extends StatelessWidget {
  const ReligiScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // jadi transparan
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF2C5364), Color(0xFF232D3F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const SafeArea(
          child: CategoryScreen(kategoriId: 1, title: 'Destinasi Religi'),
        ),
      ),
    );
  }
}
