import 'dart:io';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:open_bookshelf/exceptions/failed_to_fetch_content_exception.dart';
import 'package:open_bookshelf/exceptions/image_not_present_in_cache_exception.dart';
import 'package:open_bookshelf/exceptions/resource_already_exists_exception.dart';
import 'package:open_bookshelf/services/storage_service.dart';

const _coverEndpoint = "https://covers.openlibrary.org/b/isbn/%%-M.jpg";

class BookshelfService {
  final _storageService = GetIt.I.get<StorageService>();

  Future<Uint8List> _getDefaultCover() async {
    final bytes = await rootBundle.load('assets/images/missing_cover.jpg');
    return bytes.buffer.asUint8List();
  }

  Future<Uint8List> _fetchCoverFromInternet(String isbn) async {
    final response =
        await http.get(Uri.parse(_coverEndpoint.replaceAll("%%", isbn)));
    // If response was returned
    if (response.statusCode != HttpStatus.ok) {
      throw FailedToFetchContentException();
    }
    return response.bodyBytes;
  }

  Future<Uint8List> _fetchCoverFromCache(String isbn) async {
    try {
      return _storageService.fetchContent(
          StorageSource.imageCache, "$isbn.jpg");
    } on FailedToFetchContentException {
      throw ImageNotPresentInCacheException();
    }
  }

  Future<Uint8List> fetchCover(String? isbn) async {
    if (isbn == null) {
      return _getDefaultCover();
    }

    // Attempt to fetch cover from the Cache
    try {
      return _fetchCoverFromCache(isbn);
      // If image is not present in cache download it
    } on ImageNotPresentInCacheException {
      // Try and download image
      try {
        final fetchedImage = await _fetchCoverFromInternet(isbn);
        _storageService.storeContent(
            StorageSource.imageCache, "$isbn.jpg", fetchedImage);
        return fetchedImage;
        // If image fetch failed return the default cover
      } on FailedToFetchContentException {
        return _getDefaultCover();
      } on ResourceAlreadyExistsException {
        GetIt.I.get<Logger>().e("ImageCache internal error");
        throw Exception(
            "ImageCache failed to fetch contents from internal storage");
      }
    }
  }
}
