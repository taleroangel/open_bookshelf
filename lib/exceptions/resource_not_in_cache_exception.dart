import 'package:open_bookshelf/exceptions/open_bookshelf_exception.dart';

class ResourceNotInCacheException extends OpenBookshelfException {
  final String resource;

  const ResourceNotInCacheException({
    required this.resource,
    message = "The specified resource was not found in the device cache",
  }) : super(message: message);

  @override
  String toString() => "[Resource: $resource] ${super.toString()}";
}
