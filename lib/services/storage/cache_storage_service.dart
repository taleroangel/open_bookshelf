import 'dart:io';

import 'package:flutter/services.dart';

import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

import 'package:open_bookshelf/exceptions/failed_to_fetch_content_exception.dart';
import 'package:open_bookshelf/exceptions/resource_already_exists_exception.dart';
import 'package:open_bookshelf/exceptions/unsupported_storage_source_exception.dart';
import 'package:open_bookshelf/services/storage_service.dart';

/// Service for consulting internal device storage
class CacheStorageService implements IStorageService {
  /// Must be constructed via [getInstance] instead
  CacheStorageService._();

  /// Return global instance
  static Future<CacheStorageService> getInstance() async {
    await CacheStorageService._ensurePathsExists();

    return CacheStorageService._();
  }

  /// Ensure cache storages paths exists, if they dont, then create them
  /// Must be called before [CacheStorageService] constructor
  static Future<void> _ensurePathsExists() async {
    // Store the futures
    List<Future<Object?>> futures = [];

    // Create a future for each Directory creation
    for (var element in CacheStorageSource.values) {
      // Create directories for given element path
      futures.add(Directory(await element.path).create(recursive: true));
    }

    // Wait for all futures
    GetIt.I.get<Logger>().w("Creating required cache directories");
    await Future.wait(futures);
  }

  @override
  Future<double> sizeOf(
    covariant CacheStorageSource storageSource,
  ) async {
    // Open internal directory
    final sourceDirectory = Directory(await storageSource.path);

    // Check if the directory exits
    if (!await sourceDirectory.exists()) {
      return 0.0;
    }

    final List<Future<int>> sizes = []; // Store size of elements

    // For each element
    final items = sourceDirectory.listSync();
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

  @override
  Future<bool> delete(
    covariant CacheStorageSource storageSource,
  ) async {
    // Get source directory
    final sourceDirectory = Directory(await storageSource.path);
    GetIt.I
        .get<Logger>()
        .i("Requested cache deletion on ${sourceDirectory.path}");

    // Check if the directory exits
    if (!await sourceDirectory.exists()) {
      GetIt.I
          .get<Logger>()
          .e("Requested path '${sourceDirectory.path}' didn't exist");

      // Directory doesn't exist
      return false;
    }

    // Delete the source
    await sourceDirectory.delete(recursive: true);
    GetIt.I.get<Logger>().w("Cache deleted, directory rebuild is required");

    // Recreate storage paths
    await _ensurePathsExists();

    return true;
  }

  @override
  Future<Uint8List> fetchContent(
    covariant CacheStorageSource storageSource,
    String resource,
  ) async {
    // Get source path
    final path = "${await storageSource.path}/$resource";

    // Get file
    final file = File(path);

    // File exists
    if (!await file.exists()) {
      throw FailedToFetchContentException(resource: path);
    }

    return await file.readAsBytes();
  }

  @override
  Future<void> storeContent(
    covariant CacheStorageSource storageSource,
    String resource,
    Uint8List data,
  ) async {
    // Path to file
    final path = "${await storageSource.path}/$resource";

    // Create file
    final file = File(path);

    // Check if file already exists
    if (await file.exists()) {
      throw ResourceAlreadyExistsException(resource: path);
    }

    // Create file and write contents
    await file.create(recursive: true);
    await file.writeAsBytes(data);
  }
}

/// Source from where the image will be retrieved
enum CacheStorageSource implements StorageSource {
  images("/cache/image");

  @override
  final String directory;
  const CacheStorageSource(this.directory);

  @override
  Future<String> get path async {
    switch (this) {
      case images:
        return "${(await getApplicationSupportDirectory()).path}${images.directory}";
      default:
        throw UnsupportedStorageSourceException(
          storageType: CacheStorageSource,
        );
    }
  }
}
