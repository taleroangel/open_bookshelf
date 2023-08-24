// Flutter
// ignore_for_file: prefer-match-file-name

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:logger/logger.dart';
import 'package:open_bookshelf/services/book/internet_book_service.dart';
import 'package:open_bookshelf/services/book_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'package:open_bookshelf/application.dart';
import 'package:open_bookshelf/database/adapters/book_type_adapter.dart';
import 'package:open_bookshelf/i18n/translations.g.dart';
import 'package:open_bookshelf/models/book.dart';
import 'package:open_bookshelf/providers/bookshelf/hive_bookshelf_provider.dart';
import 'package:open_bookshelf/providers/bookshelf_provider.dart';
import 'package:open_bookshelf/providers/sideview_provider.dart';
import 'package:open_bookshelf/services/cover/cache_cover_service.dart';
import 'package:open_bookshelf/services/cover/internet_cover_service.dart';
import 'package:open_bookshelf/services/cover/system_cover_service.dart';
import 'package:open_bookshelf/services/cover_service.dart';
import 'package:open_bookshelf/services/storage/cache_storage_service.dart';

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

    //* Database initialization

    // Initialize Hive database inside support directory
    await Hive.initFlutter((await getApplicationSupportDirectory()).path);
    Hive.registerAdapter(BookTypeAdapter());

    // Open database
    await Hive.openBox<Book>(HiveBookshelfProvider.boxName);

    // Logger
    GetIt.I.registerSingleton(Logger(
      printer: kDebugMode ? PrettyPrinter() : SimplePrinter(printTime: true),
      level: kDebugMode ? Level.all : Level.warning,
    ));

    //* Register dependencies

    // Transient dependencies
    GetIt.I.registerSingleton(CacheCoverService());
    GetIt.I.registerSingleton(InternetCoverService());

    // Global dependencies
    GetIt.I.registerSingletonAsync(CacheStorageService.getInstance);
    GetIt.I.registerSingleton<ICoverService>(SystemCoverService());
    GetIt.I.registerSingleton<IBookService>(InternetBookService());

    //* Get all dependencies ready
    await GetIt.I.allReady();
    GetIt.I.get<Logger>().d("All dependencies ready");

    // Remove splash screen
    if (Platform.isAndroid || Platform.isIOS) {
      FlutterNativeSplash.remove();
    }

    //* Run the application
    runApp(TranslationProvider(
      child: MultiProvider(
        providers: [
          // Adaptive layout sideview
          ChangeNotifierProvider(create: (_) => SideviewProvider()),
          // Bookshelf providers
          ChangeNotifierProvider<IBookshelfProvider>(
            create: (_) => HiveBookshelfProvider(),
          ),
        ],
        builder: (context, child) => const Application(),
      ),
    ));
  } on Exception catch (e) {
    // Uncatched error
    GetIt.I.get<Logger>().f("Unhandled exception in main application isolate");
    // Show error and run error app
    GetIt.I.get<Logger>().e(e.toString());

    // Run application failure
    runApp(FailedApplication(exception: e));
  }
}
