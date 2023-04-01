import 'dart:io';

import 'package:flutter/services.dart';
import 'package:open_bookshelf/exceptions/failed_to_fetch_content_exception.dart';
import 'package:open_bookshelf/exceptions/resource_already_exists_exception.dart';
import 'package:path_provider/path_provider.dart';

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

/// Service for consulting internal device storage
class StorageService {
  static Future<void> ensurePathsExists() async {
    // Store the futures
    List<Future<dynamic>> futures = [];

    // Create a future for each Directory creation
    for (var element in StorageSource.values) {
      final path = await StorageSource.getSourcePath(element);
      futures.add(Directory(path).create(recursive: true));
    }

    // Wait for all futures
    await Future.wait(futures);
  }

  /// Fetch content from device internal storage
  Future<Uint8List> fetchContent(
      StorageSource storageSource, String resource) async {
    final path =
        "${await StorageSource.getSourcePath(storageSource)}/$resource";
    final file = File(path);
    if (!await file.exists()) {
      throw FailedToFetchContentException(resource: path);
    }
    return await file.readAsBytes();
  }

  /// Save content to internal storage
  void storeContent(
      StorageSource storageSource, String resource, Uint8List data) async {
    final path =
        "${await StorageSource.getSourcePath(storageSource)}/$resource";
    final file = File(path);

    if (await file.exists()) {
      throw ResourceAlreadyExistsException(resource: path);
    }

    file.create(recursive: true);
    await file.writeAsBytes(data);
  }
}
