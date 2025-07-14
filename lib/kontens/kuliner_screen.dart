import 'package:flutter/material.dart';
import 'package:new_apk/categoris/category_screen.dart';

class KulinerScreen extends StatelessWidget {
  const KulinerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CategoryScreen(
      kategoriId: 2,
      title: 'Destinasi Kuliner',
    );
  }
}
