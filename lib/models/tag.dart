import 'package:flutter/material.dart';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:open_bookshelf/database/converters/color_json_converter.dart';

part 'tag.freezed.dart';
part 'tag.g.dart';

@freezed
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
