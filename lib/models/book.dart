import 'package:flutter/material.dart';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:get_it/get_it.dart';

import 'package:open_bookshelf/i18n/translations.g.dart';
import 'package:open_bookshelf/services/cover_service.dart';

import 'tag.dart';

part 'book.freezed.dart';
part 'book.g.dart';

@freezed
class Book with _$Book {
  // Freezed book constructor
  factory Book({
    required String title,
    required String? subtitle,
    required String isbn,
    required String? url,
    @Default([]) List<String> authors,
    @Default([]) List<String> publishers,
    @Default([]) List<String> subjects,
    required String? cover,
    @Default(BookCollection.none) BookCollection collection,
    @Default({}) Set<Tag> tags,
  }) = _Book;

  factory Book.fromJson(Map<String, Object?> json) => _$BookFromJson(json);

  @override
  bool operator ==(Object other) => (other is Book) && (other.isbn == isbn);

  @override
  int get hashCode => isbn.hashCode;

  Book._();

  /// Automatically fetches cover from storage
  late final image = GetIt.I.get<ICoverService>().fetchCover(cover);
}

/// Books can be grouped into collections, this enum represents the available
/// collections and its [IconData] to be shown in a [SegmentedButton]
enum BookCollection {
  none(Icons.bookmark_border),
  reading(Icons.auto_stories),
  wishlist(Icons.lightbulb_sharp),
  read(Icons.book);

  final IconData icon;
  const BookCollection(this.icon);

  /// Fetch collection internationalized label
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
}
