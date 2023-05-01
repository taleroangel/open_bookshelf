import 'dart:io';

import 'package:flutter/material.dart';

import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

import 'package:open_bookshelf/models/book.dart';
import 'package:open_bookshelf/models/tag.dart';
import 'package:open_bookshelf/providers/bookshelf_provider.dart';

/// Fetch all [Book] in a Hive database
class HiveBookshelfProvider extends ChangeNotifier
    implements IBookshelfProvider {
  /// Hive box name
  static const boxName = 'bookshelf';

  /// Database Box
  Box<Book> _database;

  /// Open the database, Hive [Book] box must be already opened
  HiveBookshelfProvider() : _database = Hive.box<Book>(boxName) {
    GetIt.I.get<Logger>().v("$runtimeType: Database provider initialized");
  }

  Book? _selectedBook;

  @override
  Book? get selectedBook {
    if (_selectedBook != null && !exists(_selectedBook!.isbn)) {
      _selectedBook = null;
    }

    return _selectedBook;
  }

  @override
  set selectedBook(Book? book) {
    _selectedBook = book;
    notifyListeners();
  }

  @override
  bool exists(String key) => _database.containsKey(key);

  @override
  Book? operator [](String isbn) => _database.get(isbn);

  @override
  void operator []=(String isbn, Book? book) {
    // Modify or Create book if Book is not null
    // If book is null then delete it
    book != null ? _database.put(isbn, book) : _database.delete(isbn);
    notifyListeners();
  }

  @override
  Set<Book> get books => _database.values.toSet();

  @override
  Set<String> get authors => _database.values
      .map(
        (e) => e.authors,
      )
      .expand(
        (e) => e,
      )
      .toSet();

  @override
  Set<String> get publishers => _database.values
      .map(
        (e) => e.publishers,
      )
      .expand(
        (e) => e,
      )
      .toSet();

  @override
  Set<Tag> get tags => _database.values
      .map(
        (e) => e.tags,
      )
      .expand(
        (e) => e,
      )
      .toSet();

  @override
  Future<void> deleteDatabase() async {
    await _database.deleteFromDisk();
    GetIt.I.get<Logger>().w("$runtimeType: Hive database deletion completed");
    _database = await Hive.openBox<Book>(boxName);
  }

  @override
  Future<void> compactDatabase() async {
    await _database.compact();
  }

  @override
  int get length => _database.length;

  @override
  Future<double> get size async {
    final supportDirectory = await getApplicationSupportDirectory();
    final databaseFile = File("${supportDirectory.path}/$boxName.hive");

    return (await databaseFile.length()) / 1024;
  }

  @override
  DataFormat export<DataFormat>() {
    if (DataFormat == Map<String, Object?>) {
      // Transform every book into Json and cast into DataFormat
      return _database
          .toMap()
          .cast<String, Book>()
          .map(
            (key, value) => MapEntry(key, value.toJson()),
          )
          .cast<String, Object?>() as DataFormat;
    } else {
      throw UnimplementedError("$DataFormat type export is not supported");
    }
  }

  @override
  void import<DataFormat>(DataFormat data) async {
    if (DataFormat == Map<String, Object?>) {
      final books = (data as Map<String, Object?>).map((key, value) => MapEntry(
            key,
            Book.fromJson(
              (value as Map).cast<String, Object?>(),
            ),
          ));

      await _database.putAll(books);
    } else {
      throw UnimplementedError("$DataFormat type import is not supported");
    }
  }

  @override
  void importJson(Map<String, Object?> json) => import(json);

  @override
  Map<String, Object?> toJson() => export<Map<String, Object?>>();
}
