import 'dart:math';

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:get_it/get_it.dart';
import 'package:open_bookshelf/i18n/translations.g.dart';
import 'package:open_bookshelf/services/cache_storage_service.dart';
import 'tag.dart';

part 'book.freezed.dart';
part 'book.g.dart';

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
    @Default(BookCollection.none) BookCollection collection,
    @Default({}) Set<Tag> tags,
  }) = _Book;

  Book._();
  late final image = GetIt.I.get<CacheStorageService>().fetchCover(cover);

  factory Book.fromJson(Map<String, Object?> json) => _$BookFromJson(json);

  void addOrRemoveTag(Tag tag) {
    if (tags.contains(tag)) {
      tags = {...tags}..remove(tag);
    } else {
      tags = {...tags, tag};
    }
  }
}

enum BookCollection {
  none(Icons.bookmark_border),
  reading(Icons.auto_stories),
  wishlist(Icons.lightbulb_sharp),
  read(Icons.book);

  final IconData icon;
  const BookCollection(this.icon);

  static String getLabel(BookCollection collection) {
    switch (collection) {
      case BookCollection.none:
        return t.bookshelf.collections.none;
      case BookCollection.reading:
        return t.bookshelf.collections.reading;
      case BookCollection.read:
        return t.bookshelf.collections.read;
      case BookCollection.wishlist:
        return t.bookshelf.collections.wishlist;
    }
  }

  static BookCollection random() {
    final rand = Random().nextInt(BookCollection.values.length);
    return BookCollection.values[rand];
  }
}

extension BookExtension on Iterable<Book> {
  Iterable<Book> filterBooksByCollection(BookCollection collection) {
    if (collection == BookCollection.none) return this;
    return where((element) => element.collection == collection);
  }
}
