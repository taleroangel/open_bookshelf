import 'package:flutter/material.dart';
import 'package:open_bookshelf/models/book.dart';

class BookScreen extends StatelessWidget {
  final Book? book;
  const BookScreen({this.book, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book?.title ?? "No book selected"),
      ),
      body: Placeholder(),
    );
  }
}
