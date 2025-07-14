import 'package:flutter/material.dart';
import 'package:new_apk/categoris/category_screen.dart';

class ReligiScreen extends StatelessWidget {
  const ReligiScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CategoryScreen(kategoriId: 1, title: 'Destinasi Religi');
  }
}
