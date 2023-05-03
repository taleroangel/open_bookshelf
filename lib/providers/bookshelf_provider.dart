// ignore_for_file: prefer-match-file-name

import 'package:flutter/material.dart';

import 'package:open_bookshelf/models/book.dart';
import 'package:open_bookshelf/models/tag.dart';

abstract class IBookshelfProvider extends ChangeNotifier {
  /// Get the database size in KiB
  Future<double> get size;

  Book? get selectedBook;
  set selectedBook(Book? book);

  /// Get ammount of entries in database
  int get length;

  /// Delete all contents in database
  Future<void> deleteDatabase();

  /// Compact database
  Future<void> compactDatabase();

  /// Import data into databse in the specified data format
  void import<DataFormat>(DataFormat data);

  /// Export data from database in specified DataFormat
  DataFormat export<DataFormat>();

  /// Check if a Book exists
  bool exists(String key);

  /// Get Book with given ISBN
  Book? operator [](String isbn);

  /// Set book with a given ISBN
  void operator []=(String isbn, Book? book);

  /// Get books as json
  Map<String, Object?> toJson();

  /// Import books from json
  void importJson(Map<String, Object?> json);

  /// Get all books stored in database
  Set<Book> get books;

  /// Get all user created tags
  Set<Tag> get tags;

  /// Get all authors
  Set<String> get authors;

  /// Get all publishers
  Set<String> get publishers;
}

extension BookExtensions on Iterable<Book> {
  /// Get all books where [Tag] is present
  Iterable<Book> filterByTag(Tag tag) =>
      where((element) => element.tags.contains(tag));

  // Filter books by it's [BookCollection], when no collection is selected
  /// all books are returned
  Iterable<Book> filterBooksByCollection(BookCollection collection) {
    if (collection == BookCollection.none) return this;

    return where((element) => element.collection == collection);
  }
}

extension TagExtensions on Set<Tag> {
  /// Remove tag if present, add it if missing
  Set<Tag> addOrRemoveTag(Tag tag) {
    final copySet = Set<Tag>.from(this);
    contains(tag) ? (copySet.remove(tag)) : (copySet.add(tag));

    return copySet;
  }

  /// Transform to [List] and sort
  List<Tag> toSortedList() => toList()
    ..sort(
      (a, b) => a.hashCode - b.hashCode,
    );
}
