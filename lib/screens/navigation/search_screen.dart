import 'package:flutter/material.dart';
import 'package:open_bookshelf/i18n/translations.g.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t.navigation.search)),
      body: Center(
        child: Placeholder(
          color: Theme.of(context).colorScheme.primary,
          child: const Icon(
            Icons.help,
            size: 100.0,
          ),
        ),
      ),
    );
  }
}
