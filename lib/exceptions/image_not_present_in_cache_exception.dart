class ImageNotPresentInCacheException implements Exception {
  final String message;
  final String? resource;

  const ImageNotPresentInCacheException({
    this.message =
        "The specified image was not found in the device cache. The requested resource was: ",
    this.resource,
  });

  @override
  String toString() => "$message ${resource ?? 'Not specified'}";
}
