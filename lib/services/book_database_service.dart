import 'dart:async';
import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:open_bookshelf/interfaces/database_controller.dart';
import 'package:open_bookshelf/interfaces/json_manipulator.dart';
import 'package:open_bookshelf/models/book.dart';
import 'package:open_bookshelf/adapters/book_type_adapter.dart';
import 'package:open_bookshelf/models/tag.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';

class BookDatabaseService with IJsonManipulator implements IDatabaseController {
  static const localDatabaseBoxName = 'bookshelf';

  final _streamController = StreamController<DatabaseListenerEvent>.broadcast();

  Box<Book> _database;
  BookDatabaseService._(this._database) {
    _database.listenable().addListener(() {
      _streamController.add(DatabaseListenerEvent.valueChange);
    });
  }

  Stream<DatabaseListenerEvent> get stream => _streamController.stream;

  @override
  Box<Book> get database => _database;

  /// Create a new database service instance async
  static Future<BookDatabaseService> getInstance() async {
    Hive.registerAdapter(BookTypeAdapter());

    return BookDatabaseService._(
      await Hive.openBox<Book>(localDatabaseBoxName),
    );
  }

  /// Get database size (.hive file) in MiB
  @override
  Future<double> get databaseSize async {
    final supportDirectory = await getApplicationSupportDirectory();

    final databaseFile =
        File("${supportDirectory.path}/$localDatabaseBoxName.hive");

    return (await databaseFile.length()) / 1024;
  }

  /// Fetch all tags from books present in database
  Set<Tag> fetchTags() => database.isOpen
      ? database.values.map((e) => e.tags).expand((element) => element).toSet()
      : const {};

  /// Delete the database
  @override
  Future<void> deleteDatabase() async {
    _streamController.add(DatabaseListenerEvent.databaseDelete);
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
    if (DataRepresentationType == JsonDocument) {
      return toJson() as DataRepresentationType;
    } else {
      GetIt.I
          .get<Logger>()
          .e("Not implemented for $DataRepresentationType datatype");
      throw UnimplementedError();
    }
  }

  @override
  Future<void> import<DataRepresentationType>(
    DataRepresentationType data,
  ) async {
    if (DataRepresentationType == JsonDocument) {
      await fromJson(data as JsonDocument);
    } else {
      GetIt.I
          .get<Logger>()
          .e("Not implemented for $DataRepresentationType datatype");
      throw UnimplementedError();
    }
  }

  @override
  Future<int> get length async => _database.values.length;
}

enum DatabaseListenerEvent {
  databaseDelete,
  valueChange,
}
