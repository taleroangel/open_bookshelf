import 'package:flutter/material.dart';
import 'package:open_bookshelf/i18n/translations.g.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t.navigation.about)),
      body: const Placeholder(),
    );
  }
}
