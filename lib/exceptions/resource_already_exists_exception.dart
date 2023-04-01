class ResourceAlreadyExistsException implements Exception {
  final String message;
  final String? resource;

  const ResourceAlreadyExistsException(
      {this.message =
          "The content you're trying to store already exists in the device cache. The specified resource was: ",
      this.resource});

  @override
  String toString() => "$message ${resource ?? 'Not specified'}";
}
