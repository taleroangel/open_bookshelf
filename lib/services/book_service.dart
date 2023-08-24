// ignore_for_file: prefer-match-file-name

import 'package:open_bookshelf/models/book.dart';

abstract class IBookService {
  /// Fetch [Book] with given ISBN, null if book does not exist
  ///
  /// Throws [FailedToFetchContentException] if an error occurs during fetching
  Future<Book?> fetchBook(String isbn);
}
