import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

class SideviewProvider extends ChangeNotifier {
  /// Manage adaptive UI by allowing a SideView
  bool _sideviewAvailable = false;
  bool get sideviewAvailable => _sideviewAvailable;

  void sideviewEnable() {
    GetIt.I.get<Logger>().d("Sideview was enabled");
    _sideviewAvailable = true;
    notifyListeners();
  }

  void sideviewDisable() {
    GetIt.I.get<Logger>().d("Sideview was disabled");
    _sideviewAvailable = false;
    notifyListeners();
  }
}
