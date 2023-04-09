import 'package:hive_flutter/adapters.dart';
import 'package:open_bookshelf/models/book.dart';

/// Hive database [TypeAdapter] for [Book]
class BookAdapter extends TypeAdapter<Book> {
  @override
  final typeId = 0;

  @override
  Book read(BinaryReader reader) {
    return Book.fromJson(
        (reader.read() as Map<dynamic, dynamic>).cast<String, Object?>());
  }

  @override
  void write(BinaryWriter writer, Book obj) {
    writer.write(obj.toJson());
  }
}
