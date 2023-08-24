import 'dart:io';
import 'dart:typed_data';

import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import 'package:open_bookshelf/constants/open_library_endpoints.dart';
import 'package:open_bookshelf/exceptions/failed_to_fetch_content_exception.dart';
import 'package:open_bookshelf/services/cover_service.dart';

class InternetCoverService implements ICoverService {
  @override
  Future<Uint8List> fetchCover(String? coverId) async {
    // If cover is null, then throw exception
    if (coverId == null) {
      throw const FailedToFetchContentException(
        resource: "OpenLibrary book cover",
      );
    }

    // Get cover URI
    final uri = Uri.parse(OpenLibraryEndpoints.coverEndpoint(coverId));
    GetIt.I.get<Logger>().d("$runtimeType: Fetching cover from OpenLibrary");

    // Search and replace %% characters in URL
    final response = await http.get(uri);

    // If response was returned
    if (response.statusCode != HttpStatus.ok) {
      throw FailedToFetchContentException(resource: uri.toString());
    }

    return response.bodyBytes;
  }
}
