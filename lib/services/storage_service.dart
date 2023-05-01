// ignore_for_file: prefer-match-file-name

import 'dart:typed_data';

import 'package:open_bookshelf/exceptions/resource_already_exists_exception.dart';

/// Source from where the cache will be retrieved
/// Intented to be extended by enums
abstract class StorageSource {
  final String directory;
  const StorageSource(this.directory);
  Future<String> get path;
}

abstract class IStorageService {
  /// Get the size of the specified cache in MiB
  Future<double> sizeOf(StorageSource storageSource);

  /// Deletes all contents inside [StorageSource]
  /// Returns the result of the deletion
  Future<bool> delete(StorageSource storageSource);

  /// Fetch content from cache
  Future<Uint8List> fetchContent(
    StorageSource storageSource,
    String resource,
  );

  /// Store content in storage
  ///
  /// Throws [ResourceAlreadyExistsException]
  Future<void> storeContent(
    StorageSource storageSource,
    String resource,
    Uint8List data,
  );
}
