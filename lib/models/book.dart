import 'dart:math';

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:faker/faker.dart';
import 'package:open_bookshelf/i18n/translations.g.dart';

part 'book.freezed.dart';
part 'book.g.dart';

enum BookCollection {
  reading(Icons.menu_book_rounded),
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

@freezed
class Book with _$Book {
  const factory Book({
    required String title,
    required String isbn,
    String? url,
    @Default([]) List<String> authors,
    @Default([]) List<String> publishers,
    @Default([]) List<String> subjects,
    String? cover,
    @Default(BookCollection.wishlist) BookCollection collection,
  }) = _Book;

  factory Book.fromJson(Map<String, Object?> json) => _$BookFromJson(json);

  factory Book.dummy() {
    final faker = Faker();
    return Book(
      title: faker.lorem.sentence(),
      url: faker.internet.httpsUrl(),
      authors: List.generate(3, (index) => faker.person.name()),
      publishers: List.generate(2, (index) => faker.company.name()),
      subjects: List.generate(6, (index) => faker.lorem.word()),
      isbn: faker.guid.random.fromPattern(['#############']),
      collection: BookCollection.random(),
    );
  }
}
