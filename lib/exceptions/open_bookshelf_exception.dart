class OpenBookshelfException implements Exception {
  final String message;

  const OpenBookshelfException({
    required this.message,
  });

  @override
  String toString() => "$runtimeType: $message}";
}
