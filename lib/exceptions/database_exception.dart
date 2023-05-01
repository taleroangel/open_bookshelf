import 'package:open_bookshelf/exceptions/open_bookshelf_exception.dart';

class DatabaseException extends OpenBookshelfException {
  final String source;

  const DatabaseException({
    required this.source,
    message = "Failed to fetch content from source",
  }) : super(message: message);

  @override
  String toString() => "[Source: $source] ${super.toString()}";
}
