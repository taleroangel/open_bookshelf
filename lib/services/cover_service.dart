// ignore_for_file: prefer-match-file-name

import 'package:flutter/services.dart';
import 'package:open_bookshelf/exceptions/failed_to_fetch_content_exception.dart';

abstract class ICoverService {
  /// Fetch cover from storage service
  ///
  /// Throws [FailedToFetchContentException]
  Future<Uint8List> fetchCover(String? coverId);
}
