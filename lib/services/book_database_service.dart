import 'dart:io';

import 'package:open_bookshelf/interfaces/database_controller.dart';
import 'package:open_bookshelf/interfaces/json_manipulator.dart';
import 'package:open_bookshelf/models/book.dart';
import 'package:open_bookshelf/adapters/book_type_adapter.dart';
import 'package:open_bookshelf/models/tag.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';

class BookDatabaseService with IJsonManipulator implements IDatabaseController {
  static const localDatabaseBoxName = 'bookshelf';

  Box<Book> _database;
  BookDatabaseService._(this._database);

  @override
  Box<Book> get database => _database;

  /// Create a new database service instance async
  static Future<BookDatabaseService> getInstance() async {
    Hive.registerAdapter(BookTypeAdapter());

    return BookDatabaseService._(
      await Hive.openBox<Book>(localDatabaseBoxName),
    );
  }

  @override
  Future<double> get databaseSize async {
    final supportDirectory = await getApplicationSupportDirectory();

    return (await File("${supportDirectory.path}/$localDatabaseBoxName.hive")
            .length()) /
        1024;
  }

  Set<Tag> fetchTags() =>
      database.values.map((e) => e.tags).expand((element) => element).toSet();

  @override
  Future<void> deleteDatabase() async {
    await _database.deleteFromDisk();
    _database = await Hive.openBox<Book>(localDatabaseBoxName);
  }

  @override
  JsonDocument toJson() =>
      _database.toMap().map((key, value) => MapEntry(key, value.toJson()));

  @override
  Future<void> fromJson(JsonDocument json) async {
    final books = json.map((key, value) => MapEntry(key, Book.fromJson(value)));
    await _database.putAll(books);
  }

  @override
  Future<DataRepresentationType> export<DataRepresentationType>() async {
    if (DataRepresentationType.runtimeType == JsonDocument) {
      return toJson() as DataRepresentationType;
    } else {
      throw UnimplementedError();
    }
  }

  @override
  Future<void> import<DataRepresentationType>(
    DataRepresentationType data,
  ) async {
    if (DataRepresentationType.runtimeType == JsonDocument) {
      await fromJson(data as JsonDocument);
    } else {
      throw UnimplementedError();
    }
  }

  @override
  Future<int> get length async => _database.values.length;
}
