import 'package:flutter/material.dart';
import 'package:open_bookshelf/i18n/translations.g.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t.navigation.settings)),
      body: const Placeholder(),
    );
  }
}
