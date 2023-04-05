import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:logger/logger.dart';
import 'package:open_bookshelf/models/book.dart';
import 'package:open_bookshelf/services/book_database_service.dart';

/// Notification class for when a book is selected
class OnBookSelectionNotification extends Notification {}

class BookshelfProvider extends ChangeNotifier {
  /// Bookshelf Service allows book data retrieval from Database
  final BookDatabaseService _databaseService =
      GetIt.I.get<BookDatabaseService>();

  /// Currently selected book
  Book? _selectedBook;
  Book? get selectedBook => _selectedBook;
  set selectedBook(Book? book) {
    _selectedBook = book;
    notifyListeners();
  }

  Box<Book> get bookshelf => _databaseService.database;

  void updateBookCollection(BookCollection bookCollection) {
    // Update the selected book
    _selectedBook!.collection = bookCollection;
    // Update the book registry
    _databaseService.database.put(_selectedBook!.isbn, _selectedBook!);
    // Notify Listeners
    notifyListeners();
    GetIt.I
        .get<Logger>()
        .i("$runtimeType: Updated book with ISBN: ${_selectedBook?.isbn}");
  }
}
