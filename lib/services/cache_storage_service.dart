import 'dart:io';

import 'package:flutter/services.dart';
import 'package:open_bookshelf/exceptions/failed_to_fetch_content_exception.dart';
import 'package:open_bookshelf/exceptions/resource_already_exists_exception.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:open_bookshelf/exceptions/image_not_present_in_cache_exception.dart';
import 'package:open_bookshelf/constants/open_library_endpoints.dart';

/// Service for consulting internal device storage
class CacheStorageService {
  CacheStorageService._();

  /// Create a new async instance, first ensure path exists
  static Future<CacheStorageService> getInstance() async {
    await CacheStorageService._ensurePathsExists();

    return CacheStorageService._();
  }

  /// Get the size of the specified cache in MiB
  Future<double> getCacheSize(StorageSource storageSource) async {
    final List<Future<int>> sizes = []; // Store size of elements
    // Create source directory
    final source = Directory(await StorageSource.getSourcePath(storageSource));

    // Check if the directory exits
    if (!await source.exists()) {
      return 0.0;
    }

    // For each element
    final items = source.listSync();
    for (var item in items) {
      if (item is File) {
        sizes.add(item.length());
      }
    }

    // Final futures
    final futures = await Future.wait(sizes);

    return futures.isEmpty
        ? 0
        : futures.reduce((value, element) => value + element) / (1024 * 1024);
  }

  /// Deletes all contents inside [StorageSource]
  Future<bool> deleteCache(StorageSource storageSource) async {
    // Create source directory
    final source = Directory(await StorageSource.getSourcePath(storageSource));
    GetIt.I.get<Logger>().i("Requested cache deletion on ${source.path}");

    // Check if the directory exits
    if (!await source.exists()) {
      GetIt.I.get<Logger>().e("Requested path '${source.path}' didn't exist");

      return false;
    }

    // Delete the source
    await source.delete(recursive: true);
    GetIt.I.get<Logger>().w("Cache deleted, directory rebuild is required");
    await _ensurePathsExists();

    return true;
  }

  /// Ensure cache storages paths exists, if they dont, then create them
  /// Must be called before [CacheStorageService] constructor
  static Future<void> _ensurePathsExists() async {
    // Store the futures
    List<Future<Object?>> futures = [];

    // Create a future for each Directory creation
    for (var element in StorageSource.values) {
      final path = await StorageSource.getSourcePath(element);
      futures.add(Directory(path).create(recursive: true));
    }

    // Wait for all futures
    GetIt.I.get<Logger>().w("Creating required cache directories");
    await Future.wait(futures);
  }

  /// Fetch content from device internal storage
  Future<Uint8List> fetchContent(
    StorageSource storageSource,
    String resource,
  ) async {
    final path =
        "${await StorageSource.getSourcePath(storageSource)}/$resource";
    final file = File(path);
    if (!await file.exists()) {
      throw FailedToFetchContentException(resource: path);
    }

    return await file.readAsBytes();
  }

  /// Save content to internal storage
  Future<void> storeContent(
    StorageSource storageSource,
    String resource,
    Uint8List data,
  ) async {
    final path =
        "${await StorageSource.getSourcePath(storageSource)}/$resource";
    final file = File(path);

    if (await file.exists()) {
      throw ResourceAlreadyExistsException(resource: path);
    }

    await file.create(recursive: true);
    await file.writeAsBytes(data);
  }

  /// Get the default book cover
  Future<Uint8List> _getDefaultCover() async {
    final bytes = await rootBundle.load('assets/images/missing_cover.png');

    return bytes.buffer.asUint8List();
  }

  /// Fetch a cover by its book ISBN
  Future<Uint8List> _fetchCoverFromInternet(String coverId) async {
    final uri = Uri.parse(OpenLibraryEndpoints.coverEndpoint(coverId));
    final response = // Search and replace %% characters in URL
        await http.get(uri);
    // If response was returned
    if (response.statusCode != HttpStatus.ok) {
      throw FailedToFetchContentException(resource: uri.toString());
    }

    return response.bodyBytes;
  }

  /// Fetch a cover from device internal cache
  Future<Uint8List> _fetchCoverFromCache(String coverId) async {
    final resource = "$coverId.jpg";
    try {
      return await fetchContent(StorageSource.imageCache, resource);
    } on FailedToFetchContentException {
      throw ImageNotPresentInCacheException(resource: resource);
    }
  }

  /// Fetch cover, will attempt to retrieve it from cache first, if it
  /// doesn't exist it will download it from internet and store it in cache
  /// if neither is possible then it returns the default cover
  Future<Uint8List> fetchCover(String? coverId) async {
    if (coverId == null) {
      return await _getDefaultCover();
    }

    // Attempt to fetch cover from the Cache
    try {
      GetIt.I.get<Logger>().d("Cover: Fetching cover from cache...");
      // If image is not present in cache download it

      return await _fetchCoverFromCache(coverId);
    } on ImageNotPresentInCacheException {
      // Try and download image
      GetIt.I
          .get<Logger>()
          .w("Cover: not present in cache, downloading from internet");

      try {
        // Fetch cover from internet
        final fetchedImage = await _fetchCoverFromInternet(coverId);
        // Store the cover on cache
        storeContent(StorageSource.imageCache, "$coverId.jpg", fetchedImage)
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
          "ImageCache failed to fetch contents from internal storage",
        );
      }
    }
  }
}

/// Source from where the image will be retrieved
enum StorageSource {
  imageCache("/cache/image");

  final String subDirectory;
  const StorageSource(this.subDirectory);

  static Future<String> getSourcePath(StorageSource storageSource) async {
    switch (storageSource) {
      case StorageSource.imageCache:
        return "${(await getApplicationSupportDirectory()).path}${storageSource.subDirectory}";
    }
  }
}
