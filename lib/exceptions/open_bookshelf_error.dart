class OpenBookshelfError extends Error {
  final String message;

  OpenBookshelfError(this.message);

  @override
  String toString() => "[Fatal Error] $runtimeType: $message}";
}
