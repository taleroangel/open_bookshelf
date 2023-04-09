import 'dart:math';

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:get_it/get_it.dart';
import 'package:open_bookshelf/i18n/translations.g.dart';
import 'package:open_bookshelf/services/cache_storage_service.dart';

part 'book.freezed.dart';
part 'book.g.dart';

enum BookCollection {
  reading(Icons.auto_stories),
  wishlist(Icons.lightbulb_sharp),
  read(Icons.book);

  final IconData icon;
  const BookCollection(this.icon);

  static String getLabel(BookCollection collection) {
    switch (collection) {
      case BookCollection.reading:
        return t.navigation.reading;
      case BookCollection.read:
        return t.navigation.read;
      case BookCollection.wishlist:
        return t.navigation.wishlist;
    }
  }

  static BookCollection random() {
    final rand = Random().nextInt(BookCollection.values.length);
    return BookCollection.values[rand];
  }
}

@unfreezed
class Book with _$Book {
  // Freezed book constructor
  factory Book({
    required final String title,
    final String? subtitle,
    required final String isbn,
    final String? url,
    @Default([]) final List<String> authors,
    @Default([]) final List<String> publishers,
    @Default([]) final List<String> subjects,
    String? cover,
    @Default(BookCollection.wishlist) BookCollection collection,
  }) = _Book;

  Book._();
  late final image = GetIt.I.get<CacheStorageService>().fetchCover(cover);

  factory Book.fromJson(Map<String, Object?> json) => _$BookFromJson(json);
}
