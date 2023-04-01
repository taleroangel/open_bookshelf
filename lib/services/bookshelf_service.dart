import 'dart:io';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:open_bookshelf/exceptions/failed_to_fetch_content_exception.dart';
import 'package:open_bookshelf/exceptions/image_not_present_in_cache_exception.dart';
import 'package:open_bookshelf/exceptions/resource_already_exists_exception.dart';
import 'package:open_bookshelf/services/storage_service.dart';

/* --------- API Endpoints --------- */
const _coverEndpoint = "https://covers.openlibrary.org/b/isbn/%%-M.jpg";

/// Provide services for Bookshelf data fetching
class BookshelfService {
  final _storageService = GetIt.I.get<StorageService>();

  /* --------- Covers --------- */

  /// Get the default book cover
  Future<Uint8List> _getDefaultCover() async {
    final bytes = await rootBundle.load('assets/images/missing_cover.jpg');
    return bytes.buffer.asUint8List();
  }

  /// Fetch a cover by its book ISBN using [_coverEndpoint] as URL
  Future<Uint8List> _fetchCoverFromInternet(String isbn) async {
    final uri = Uri.parse(_coverEndpoint.replaceAll("%%", isbn));
    final response = // Search and replace %% characters in URL
        await http.get(uri);
    // If response was returned
    if (response.statusCode != HttpStatus.ok) {
      throw FailedToFetchContentException(resource: uri.toString());
    }
    return response.bodyBytes;
  }

  /// Fetch a cover from device internal cache
  Future<Uint8List> _fetchCoverFromCache(String isbn) async {
    final resource = "$isbn.jpg";
    try {
      return await _storageService.fetchContent(
          StorageSource.imageCache, resource);
    } on FailedToFetchContentException {
      throw ImageNotPresentInCacheException(resource: resource);
    }
  }

  /// Fetch cover, will attempt to retrieve it from cache first, if it
  /// doesn't exist it will download it from internet and store it in cache
  /// if neither is possible then it returns the default cover
  Future<Uint8List> fetchCover(String? cover) async {
    if (cover == null) {
      return await _getDefaultCover();
    }

    // Attempt to fetch cover from the Cache
    try {
      GetIt.I.get<Logger>().d("Cover: Fetching cover from cache...");
      // If image is not present in cache download it
      return await _fetchCoverFromCache(cover);
    } on ImageNotPresentInCacheException {
      // Try and download image
      GetIt.I
          .get<Logger>()
          .e("Cover: not present in cache, downloading from internet");

      try {
        // Fetch cover from internet
        final fetchedImage = await _fetchCoverFromInternet(cover);
        // Store the cover on cache
        _storageService
            .storeContent(StorageSource.imageCache, "$cover.jpg", fetchedImage)
            .then((value) {
          // Log the result
          GetIt.I.get<Logger>().i("Cover: image fetched from internet cached");
        });

        return fetchedImage;
        // If image fetch failed return the default cover
      } on FailedToFetchContentException {
        GetIt.I.get<Logger>().e("Cover: Failed to fetch from internet");
        // Return the default cover
        return await _getDefaultCover();

        // This exceptions is returned when image already existed on cache
        // but cache was already checked so an error ocurred in cache
      } on ResourceAlreadyExistsException {
        GetIt.I.get<Logger>().e("Cache: ImageCache internal error");
        throw Exception(
            "ImageCache failed to fetch contents from internal storage");
      }
    }
  }
}
