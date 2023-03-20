import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:open_bookshelf/services/bookshelf_service.dart';

class BookshelfProvider extends ChangeNotifier {
  final BookshelfService service;
  BookshelfProvider() : service = GetIt.I.get<BookshelfService>();
}
