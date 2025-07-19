import 'package:flutter/material.dart';
import 'package:new_apk/categoris/category_screen.dart';

class OlehOlehScreen extends StatelessWidget {
  const OlehOlehScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CategoryScreen(
      kategoriId: 4,
      title: 'Oleh-oleh Khas Indramayu',
    );
  }
}
