import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:open_bookshelf/models/book.dart';
import 'package:open_bookshelf/screens/book_screen.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';

/// Display a [BookScreen] depending on [AdaptiveScaffold]
/// Small devices push the [BookScreen] with [MaterialPageRoute]
/// Large devices have a [BookPreviewSideview] as a sideview which containts the [BookScreen]
/// everytime a new [Book] wants to be shown, [navigateToBook] should be called
class BookPreviewProvider extends ChangeNotifier {
  bool _sideviewAvailable = false;
  bool get sideviewAvailable => _sideviewAvailable;

  Widget? _sidePreview;
  Widget? get sidePreview => _sidePreview;

  void sideviewEnable() {
    GetIt.I.get<Logger>().d("Sideview was enabled");
    _sideviewAvailable = true;
    _sidePreview = const BookScreen();
  }

  void sideviewDisable() {
    GetIt.I.get<Logger>().d("Sideview was disabled");
    _sideviewAvailable = false;
    _sidePreview = null;
  }

  dynamic navigateToBook(BuildContext context, Book book) {
    if (_sideviewAvailable) {
      _sidePreview = BookScreen(
        book: book,
      );
      notifyListeners();
    } else {
      return Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => BookScreen(
                book: book,
              )));
    }
  }
}
