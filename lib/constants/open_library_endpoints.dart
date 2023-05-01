/// static only class for consulting OpenLibrary's APIs
abstract class OpenLibraryEndpoints {
  /// Link to contribute page on OpenLibrary
  static get contribute => "https://openlibrary.org/help/faq/editing";

  /// Get a book by it's ISBN code endpoint
  static String isbnEndpoint(String isbn) =>
      "https://openlibrary.org/api/books?bibkeys=ISBN:$isbn&jscmd=details&format=json";

  /// Get a book cover by it's Cover ID endpoint
  static String coverEndpoint(String id) =>
      "https://covers.openlibrary.org/b/id/$id-L.jpg?default=false";
}
