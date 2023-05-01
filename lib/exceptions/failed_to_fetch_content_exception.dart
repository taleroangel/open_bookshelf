import 'package:open_bookshelf/exceptions/open_bookshelf_exception.dart';

class FailedToFetchContentException extends OpenBookshelfException {
  final String resource;

  const FailedToFetchContentException({
    required this.resource,
    message = "Failed to fetch content from source",
  }) : super(message: message);

  @override
  String toString() => "[Resource: $resource] ${super.toString()}";
}
