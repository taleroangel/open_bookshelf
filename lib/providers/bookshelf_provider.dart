import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:open_bookshelf/models/book.dart';
import 'package:open_bookshelf/services/bookshelf_service.dart';

/// Notification class for when a book is selected
class OnBookSelectionNotification extends Notification {}

class BookshelfProvider extends ChangeNotifier {
  /// Bookshelf Service allows book data retrieval from Database
  final BookshelfService service = GetIt.I.get<BookshelfService>();

  /// Currently selected book
  Book? _currentBook;
  Book? get selectedBook => _currentBook;
  set selectedBook(Book? book) {
    _currentBook = book;
    notifyListeners();
  }

  /// Books database
  final _books = List<Book>.generate(20, (index) => Book.dummy())
      .asMap()
      .map((key, value) => MapEntry(value.isbn, value));

  Map<String, Book> get books => Map.unmodifiable(_books);

  void updateBookCollection(BookCollection bookCollection) {
    // Update the book registry
    _books[_currentBook?.isbn]?.collection = bookCollection;
    // Notify Listeners
    notifyListeners();
    GetIt.I
        .get<Logger>()
        .i("$runtimeType: Updated book with ISBN: ${_currentBook?.isbn}");
  }
}
