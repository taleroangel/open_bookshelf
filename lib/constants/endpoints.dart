class OpenLibraryEndpoints {
  OpenLibraryEndpoints._();

  static String isbnEndpoint(String isbn) =>
      "https://openlibrary.org/api/books?bibkeys=ISBN:$isbn&jscmd=details&format=json";

  static String coverEndpoint(String id) =>
      "https://covers.openlibrary.org/b/id/$id-L.jpg?default=false";

  static const contribute = "https://openlibrary.org/help/faq/editing";
}
