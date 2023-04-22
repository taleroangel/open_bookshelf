class DatabaseException implements Exception {
  final String message;

  const DatabaseException({
    this.message = "Failed to fetch content from source: ",
  });

  @override
  String toString() => "DatabaseException: $message}";
}
