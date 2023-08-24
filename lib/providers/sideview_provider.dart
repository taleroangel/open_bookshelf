import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

/// Provider to handle the Adaptive's ui sideview
class SideviewProvider extends ChangeNotifier {
  /// Manage adaptive UI by allowing a SideView
  bool _sideviewAvailable = false;
  bool get sideviewAvailable => _sideviewAvailable;

  /// Called by [SideviewWidget] on creation to indicate that a sideview
  /// is available for usage
  void sideviewEnable() {
    GetIt.I.get<Logger>().t("Sideview was enabled");
    _sideviewAvailable = true;
    notifyListeners();
  }

  /// Called by [SideviewWidget] on disposal to indicate that a sideview
  /// is not longer available
  void sideviewDisable() {
    GetIt.I.get<Logger>().t("Sideview was disabled");
    _sideviewAvailable = false;
    notifyListeners();
  }
}
