import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:open_bookshelf/models/book.dart';
import 'package:open_bookshelf/services/bookshelf_service.dart';

class BookshelfProvider extends ChangeNotifier {
  final BookshelfService service = GetIt.I.get<BookshelfService>();

  final _books = List<Book>.generate(20, (index) => Book.dummy())
      .asMap()
      .map((key, value) => MapEntry(value.isbn, value));

  Map<String, Book> get books => Map.unmodifiable(_books);

  Book? getBookByISBN(String? isbn) {
    return _books[isbn];
  }

  void updateBook(Book book) {
    _books[book.isbn] = book;
    GetIt.I
        .get<Logger>()
        .i("$runtimeType: Updated book with ISBN: ${book.isbn}");
    notifyListeners();
  }
}
