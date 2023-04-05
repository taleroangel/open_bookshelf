import 'dart:io';

import 'package:hive_flutter/adapters.dart';
import 'package:open_bookshelf/models/book.dart';
import 'package:open_bookshelf/adapters/book_adapter.dart';
import 'package:path_provider/path_provider.dart';

class BookDatabaseService {
  static const localDatabaseBoxName = 'bookshelf';

  final Box<Book> _database;
  BookDatabaseService._(this._database);

  Box<Book> get database => _database;

  /// Create a new database service instance async
  static Future<BookDatabaseService> getInstance() async {
    Hive.registerAdapter(BookAdapter()); // Register the Book adapter
    return BookDatabaseService._(
        await Hive.openBox<Book>(localDatabaseBoxName));
  }

  /// Get the database size
  Future<double> getDatabaseSize() async {
    final supportDirectory = await getApplicationSupportDirectory();
    return (await File("${supportDirectory.path}/$localDatabaseBoxName.hive")
            .length()) /
        1024;
  }

  Map<dynamic, dynamic> getDatabaseJson() =>
      _database.toMap().map((key, value) => MapEntry(key, value.toJson()));
}
