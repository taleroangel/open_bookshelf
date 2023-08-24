import 'package:open_bookshelf/exceptions/open_bookshelf_exception.dart';

class UnsupportedStorageSourceException extends OpenBookshelfException {
  UnsupportedStorageSourceException({
    required Type storageType,
  }) : super(message: "Storage does not support $storageType");
}
