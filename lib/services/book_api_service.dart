import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:open_bookshelf/exceptions/failed_to_fetch_content_exception.dart';
import 'package:open_bookshelf/models/book.dart';
import 'package:http/http.dart' as http;
import 'package:open_bookshelf/constants/endpoints.dart' as endpoints;

class BookApiService {
  Future<Book?> fetchBookFromOpenLibrary(String isbn) async {
    // HTTP Response
    try {
      // Response from HTTP
      GetIt.I.get<Logger>().i("OpenLibrary API ISBN request in progress");
      final httpResponse = await http.get(Uri.parse(
          endpoints.openLibrary["isbn_endpoint"]!.replaceAll("%%", isbn)));

      if (httpResponse.statusCode == 200) {
        // Decode json body
        final decodedBody = jsonDecode(httpResponse.body);

        // If no response
        if (decodedBody.isEmpty) {
          return null;
        }

        // Parse contents
        Map<String, dynamic> apiResponse =
            (decodedBody as Map<String, dynamic>).values.first;

        // Book from json
        return Book.fromJson({
          "cover": (apiResponse['details']['covers'] as List<dynamic>?)
              ?.first
              .toString(),
          "title": apiResponse['details']['full_title'] ??
              apiResponse['details']['title'],
          "subtitle": apiResponse['details']['subtitle'],
          "isbn": apiResponse['details']['isbn_13'][0] ??
              apiResponse['details']['isbn_10'][0],
          "url": apiResponse['info_url'],
          "authors":
              ((apiResponse['details']['authors'] ?? []) as List<dynamic>)
                  .map((e) => e['name']?.toString())
                  .toList(),
          "publishers": apiResponse['details']['publishers'] ?? [],
          "subjects": apiResponse['details']['subject'] ?? []
        });
      } else {
        // Return a null value
        return null;
      }
    } catch (e) {
      GetIt.I.get<Logger>().e("Failed to fetch data from OpenLibrary: $e");
      throw FailedToFetchContentException(resource: isbn);
    }
  }
}
