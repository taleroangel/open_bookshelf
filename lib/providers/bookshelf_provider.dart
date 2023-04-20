import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:logger/logger.dart';
import 'package:open_bookshelf/services/book_database_service.dart';
import 'package:open_bookshelf/models/book.dart';
import 'package:open_bookshelf/models/tag.dart';

class BookshelfProvider extends ChangeNotifier {
  BookshelfProvider() {
    // Change to the database also prompts changes to the listeners
    _tags = _databaseService.fetchTags();
    _databaseService.database.listenable().addListener(() {
      _tags = _databaseService.fetchTags();
      notifyListeners();
    });
  }

  // Tags cache
  Set<Tag> _tags = {};
  Set<Tag> get tags => _tags;

  /// Currently selected book
  Book? _currentlySelectedBook;
  Book? get currentlySelectedBook => _currentlySelectedBook;
  set currentlySelectedBook(Book? book) {
    _currentlySelectedBook = book;
    notifyListeners();
  }

  /// Bookshelf Service allows book data retrieval from Database
  final BookDatabaseService _databaseService =
      GetIt.I.get<BookDatabaseService>();
  Box<Book> get bookshelf => _databaseService.database;

  Future<bool> deleteCurrentBook() async {
    if (_currentlySelectedBook == null) return false;
    await _databaseService.database.delete(_currentlySelectedBook!.isbn);
    currentlySelectedBook = null;

    return true;
  }

  /// Change the currentlySelectedBook collection type, this is (alongside cover)
  /// the only mutable fields of [Book]
  void updateBookCollection(BookCollection bookCollection) {
    // Update the selected book
    _currentlySelectedBook!.collection = bookCollection;
    // Update the book registry
    _databaseService.database
        .put(_currentlySelectedBook!.isbn, _currentlySelectedBook!);
    // Notify Listeners
    notifyListeners();

    GetIt.I.get<Logger>().i(
          "$runtimeType: Updated book with ISBN: ${_currentlySelectedBook?.isbn}",
        );
  }

  /// Add or Remove a tag from the currently selected book
  void addOrRemoveBookTag(Tag tag) {
    _currentlySelectedBook!.addOrRemoveTag(tag);
    _databaseService.database
        .put(_currentlySelectedBook!.isbn, _currentlySelectedBook!);
    notifyListeners();
    GetIt.I.get<Logger>().i(
          "$runtimeType: Updated book with ISBN: ${_currentlySelectedBook?.isbn}",
        );
  }

  List<Book> booksWithTag(Tag tag) =>
      bookshelf.values.where((element) => element.tags.contains(tag)).toList();
}

/// Notification class for when a book is selected
class OnBookSelectionNotification extends Notification {}
