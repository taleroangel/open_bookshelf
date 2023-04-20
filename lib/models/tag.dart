import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'tag.freezed.dart';
part 'tag.g.dart';

@Freezed()
class Tag with _$Tag {
  const factory Tag({
    required String name,
    @ColorJsonConverter() required Color color,
  }) = _Tag;

  factory Tag.fromJson(Map<String, Object?> json) => _$TagFromJson(json);

  const Tag._();

  @override
  bool operator ==(Object other) => other is Tag && other.name == name;

  @override
  int get hashCode => name.hashCode;
}

class ColorJsonConverter extends JsonConverter<Color, int> {
  const ColorJsonConverter();

  @override
  Color fromJson(int json) {
    return Color(json);
  }

  @override
  int toJson(Color object) {
    return object.value;
  }
}
