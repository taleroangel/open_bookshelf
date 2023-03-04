import 'package:flutter/material.dart';
import 'package:open_bookshelf/i18n/translations.g.dart';

enum BookshelfFilter { reading, read, favorites, wishlist }

class BookshelfScreen extends StatelessWidget {
  final BookshelfFilter filter;
  const BookshelfScreen(this.filter, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t.navigation.bookshelf)),
      body: const Placeholder(),
    );
  }
}
