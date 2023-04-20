// Flutter
// ignore_for_file: prefer-match-file-name

typedef JsonDocument = Map<String, dynamic>;

abstract class IJsonManipulator {
  JsonDocument get json => toJson();
  JsonDocument toJson();
  void fromJson(JsonDocument json);
}