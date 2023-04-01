class FailedToFetchContentException implements Exception {
  final String message;
  final String? resource;

  const FailedToFetchContentException(
      {this.message = "Failed to fetch content from source: ", this.resource});

  @override
  String toString() => "$message ${resource ?? 'Not specified'}";
}
