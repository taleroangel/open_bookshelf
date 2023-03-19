import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:open_bookshelf/i18n/translations.g.dart';
import 'package:open_bookshelf/models/book.dart';
import 'package:open_bookshelf/providers/book_preview_provider.dart';
import 'package:provider/provider.dart';

enum BookshelfFilter { reading, read, favorites, wishlist }

class BookshelfScreen extends StatelessWidget {
  final BookshelfFilter filter;
  const BookshelfScreen(this.filter, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t.navigation.bookshelf)),
      body: ElevatedButton(
          onPressed: () => context
              .read<BookPreviewProvider>()
              .navigateToBook(context, Book.dummy()),
          child: Text("Try!")),
    );
  }
}
