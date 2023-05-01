import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:open_bookshelf/exceptions/failed_to_fetch_content_exception.dart';
import 'package:open_bookshelf/services/cover/cache_cover_service.dart';
import 'package:open_bookshelf/services/cover/internet_cover_service.dart';
import 'package:open_bookshelf/services/cover_service.dart';

class SystemCoverService implements ICoverService {
  /// Underlying services
  late final _cacheCoverService = GetIt.I.get<CacheCoverService>();
  late final _internetCoverService = GetIt.I.get<InternetCoverService>();

  /// Get 'missing cover' from assets
  Future<Uint8List> get defaultCover async {
    final bytes = await rootBundle.load('assets/images/missing_cover.png');

    return bytes.buffer.asUint8List();
  }

  @override
  Future<Uint8List> fetchCover(String? coverId) {
    try {
      return _cacheCoverService.fetchCover(coverId);
    } on FailedToFetchContentException {
      try {
        return _internetCoverService.fetchCover(coverId);
      } on FailedToFetchContentException {
        return defaultCover;
      }
    }
  }
}
