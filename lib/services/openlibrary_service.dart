import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:open_bookshelf/exceptions/failed_to_fetch_content_exception.dart';
import 'package:open_bookshelf/models/book.dart';
import 'package:http/http.dart' as http;
import 'package:open_bookshelf/constants/open_library_endpoints.dart';

/// Service class with abstractions to handle the OpenLibrary's API..
class OpenlibraryService {
  /// Fetch a [Book] by it's ISBN from OpenLibrary's Book API..
  Future<Book?> fetchBook(String isbn) async {
    try {
      GetIt.I.get<Logger>().i("OpenLibrary API ISBN request in progress");
      // Response from HTTP.
      final httpResponse =
          await http.get(Uri.parse(OpenLibraryEndpoints.isbnEndpoint(isbn)));

      if (httpResponse.statusCode == 200) {
        // Decode json body.
        final decodedBody = jsonDecode(httpResponse.body);

        // OpenLibrary API won't return 404 on failure,
        // instead it will return an empty body so handle that here.
        if (decodedBody.isEmpty) {
          return null;
        }

        // Parse contents as a Map<>.
        Map<String, dynamic> apiResponse =
            (decodedBody as Map<String, dynamic>).values.first;

        // Book from json.
        return Book.fromJson({
          "cover": (apiResponse['details']['covers'] as List<Object?>?)
              ?.first
              .toString(),
          "title": apiResponse['details']['full_title'] ??
              apiResponse['details']['title'],
          "subtitle": apiResponse['details']['subtitle'],
          "isbn": (apiResponse['details']['isbn_13'] ??
              apiResponse['details']['isbn_10'])[0],
          "url": apiResponse['info_url'],
          "authors":
              ((apiResponse['details']['authors'] ?? []) as List<Object?>)
                  .cast<Map<String, dynamic>>()
                  .map((e) => e['name']?.toString())
                  .toList(),
          "publishers": apiResponse['details']['publishers'] ?? [],
          "subjects": apiResponse['details']['subject'] ?? [],
        });
      } else {
        // Return a null value i.e no book was found.
        return null;
      }
    } catch (e) {
      // Failed to parse book information, thats an error.
      GetIt.I.get<Logger>().e("Failed to fetch data from OpenLibrary: $e");
      throw FailedToFetchContentException(resource: isbn);
    }
  }
}
