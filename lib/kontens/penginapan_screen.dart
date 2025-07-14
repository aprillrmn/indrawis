import 'package:flutter/material.dart';
import 'package:new_apk/categoris/category_screen.dart';

class PenginapanScreen extends StatelessWidget {
  const PenginapanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CategoryScreen(
      kategoriId: 3, 
      title: 'Destinasi Penginapan',
    );
  }
}
