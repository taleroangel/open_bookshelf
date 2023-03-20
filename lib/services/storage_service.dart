import 'dart:io';

import 'package:flutter/services.dart';
import 'package:open_bookshelf/exceptions/failed_to_fetch_content_exception.dart';
import 'package:open_bookshelf/exceptions/resource_already_exists_exception.dart';
import 'package:path_provider/path_provider.dart';

enum StorageSource {
  imageCache("/cache/image");

  final String subDirectory;
  const StorageSource(this.subDirectory);

  static Future<String> getSourcePath(StorageSource storageSource) async {
    switch (storageSource) {
      case StorageSource.imageCache:
        return "${(await getApplicationDocumentsDirectory()).path}${storageSource.subDirectory}";
    }
  }
}

/// Device internal storage Service
class StorageService {
  /// Fetch content from device internal storage
  Future<Uint8List> fetchContent(
      StorageSource storageSource, String resource) async {
    final path =
        "${await StorageSource.getSourcePath(storageSource)}/$resource";
    final file = File(path);
    if (!await file.exists()) {
      throw FailedToFetchContentException();
    }
    return file.readAsBytes();
  }

  /// Save content to internal storage
  void storeContent(
      StorageSource storageSource, String resource, Uint8List data) async {
    final path =
        "${await StorageSource.getSourcePath(storageSource)}/$resource";
    final file = File(path);
    if (await file.exists()) {
      throw ResourceAlreadyExistsException();
    }

    file.create();
    await file.writeAsBytes(data);
  }
}
