import 'package:flutter/services.dart';

import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import 'package:open_bookshelf/exceptions/failed_to_fetch_content_exception.dart';
import 'package:open_bookshelf/services/storage/cache_storage_service.dart';
import 'package:open_bookshelf/services/cover_service.dart';

class CacheCoverService implements ICoverService {
  CacheCoverService._(this.cacheStorageService);

  static Future<CacheCoverService> getInstance() async =>
      CacheCoverService._(await CacheStorageService.getInstance());

  late final CacheStorageService cacheStorageService;

  @override
  Future<Uint8List> fetchCover(String? coverId) async {
    // If cover is null, then throw exception
    if (coverId == null) {
      throw const FailedToFetchContentException(
        resource: "OpenLibrary book cover",
      );
    }
    // Attempt to fetch cover from the Cache
    GetIt.I.get<Logger>().d("Cover: Fetching cover from cache...");
    // If image is not present in cache download it

    // Return content
    return await cacheStorageService.fetchContent(
      CacheStorageSource.images,
      "$coverId.jpg",
    );
  }
}
