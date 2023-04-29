// Flutter
// ignore_for_file: prefer-match-file-name

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:open_bookshelf/application.dart';

// Services
import 'package:open_bookshelf/services/cache_storage_service.dart';
import 'package:open_bookshelf/services/book_database_service.dart';
import 'package:open_bookshelf/services/openlibrary_service.dart';

// Other
import 'package:open_bookshelf/i18n/translations.g.dart';
import 'package:open_bookshelf/services/settings_service.dart';

// Packages
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  try {
    // Flutter is initialized
    final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

    // Add splash screen
    if (Platform.isAndroid || Platform.isIOS) {
      FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
    }

    // Initialize Locale
    LocaleSettings.useDeviceLocale();

    // Initialize Hive database inside support directory
    await Hive.initFlutter((await getApplicationSupportDirectory()).path);

    // Logger
    GetIt.I.registerSingleton(Logger(
      printer: PrettyPrinter(),
      level: kDebugMode ? Level.verbose : Level.warning,
    ));

    // Register all services and dependencies
    GetIt.I.registerSingleton(OpenlibraryService());
    GetIt.I.registerSingletonAsync(CacheStorageService.getInstance);
    GetIt.I.registerSingletonAsync(BookDatabaseService.getInstance);

    // Services that depend on other services
    await GetIt.I.isReady<BookDatabaseService>();
    GetIt.I.registerSingleton(SettingsService(
      databaseController: GetIt.I.get<BookDatabaseService>(),
    ));

    // Get all dependencies ready
    await GetIt.I.allReady();
    GetIt.I.get<Logger>().d("All dependencies ready");

    // Remove splash screen
    if (Platform.isAndroid || Platform.isIOS) {
      FlutterNativeSplash.remove();
    }

    // Run the application
    runApp(TranslationProvider(child: const Application()));
  } catch (e) {
    // Uncatched error
    GetIt.I
        .get<Logger>()
        .wtf("Unhandled exception in main application isolate");
    runApp(FailedApplication(exception: e));
  }
}
