import 'package:open_bookshelf/exceptions/open_bookshelf_exception.dart';

class ResourceAlreadyExistsException extends OpenBookshelfException {
  final String resource;

  const ResourceAlreadyExistsException({
    required this.resource,
    message =
        "The content you're trying to store already exists in the device cache",
  }) : super(message: message);

  @override
  String toString() => "[Resource: $resource] ${super.toString()}";
}
