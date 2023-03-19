import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:faker/faker.dart';

part 'book.freezed.dart';
part 'book.g.dart';

@freezed
class Book with _$Book {
  const factory Book(
      {required String title,
      required List<String> authors,
      required List<String> publishers,
      required String isbn,
      required String? cover}) = _Book;

  factory Book.fromJson(Map<String, Object?> json) => _$BookFromJson(json);

  factory Book.dummy() {
    final faker = Faker();
    return Book(
        title: faker.lorem.sentence(),
        authors: List.generate(3, (index) => faker.person.name()),
        publishers: List.generate(2, (index) => faker.company.name()),
        isbn: "9783161484100",
        cover: null);
  }
}
