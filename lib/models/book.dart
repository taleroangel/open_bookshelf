import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:faker/faker.dart';
import 'package:open_bookshelf/i18n/translations.g.dart';

part 'book.freezed.dart';
part 'book.g.dart';

enum BookCollection {
  reading,
  read,
  wishlist;

  static IconData getAsIcon(BookCollection collection) {
    switch (collection) {
      case BookCollection.reading:
        return Icons.menu_book_rounded;
      case BookCollection.read:
        return Icons.book;
      case BookCollection.wishlist:
        return Icons.lightbulb_sharp;
    }
  }

  static String getAsText(BookCollection collection) {
    switch (collection) {
      case BookCollection.reading:
        return t.navigation.reading;
      case BookCollection.read:
        return t.navigation.read;
      case BookCollection.wishlist:
        return t.navigation.wishlist;
    }
  }
}

@freezed
class Book with _$Book {
  const factory Book({
    required String title,
    required List<String> authors,
    required List<String> publishers,
    required String isbn,
    String? description,
    String? cover,
    required BookCollection collection,
  }) = _Book;

  factory Book.fromJson(Map<String, Object?> json) => _$BookFromJson(json);

  factory Book.dummy() {
    final faker = Faker();
    return Book(
        title: faker.lorem.sentence(),
        authors: List.generate(3, (index) => faker.person.name()),
        publishers: List.generate(2, (index) => faker.company.name()),
        isbn: "9783161484100",
        description: random.integer(3) == 1
            ? faker.lorem
                .sentences(random.integer(30, min: 2))
                .reduce((value, element) => "$value $element")
            : null,
        collection: BookCollection.reading);
  }
}
