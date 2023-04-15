import 'dart:convert';

import 'package:hive_flutter/adapters.dart';
import 'package:open_bookshelf/models/book.dart';

/// Hive database [TypeAdapter] for [Book]
class BookAdapter extends TypeAdapter<Book> {
  @override
  int get typeId => 0;

  @override
  Book read(BinaryReader reader) =>
      Book.fromJson(jsonDecode(reader.read()).cast<String, Object?>());

  @override
  void write(BinaryWriter writer, Book obj) =>
      writer.write(jsonEncode(obj.toJson()));
}
