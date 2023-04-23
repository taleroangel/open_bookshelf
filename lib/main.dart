// Flutter
// ignore_for_file: prefer-match-file-name

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Providers
import 'package:open_bookshelf/providers/bookshelf_provider.dart';
import 'package:open_bookshelf/providers/sideview_provider.dart';

// Services
import 'package:open_bookshelf/services/cache_storage_service.dart';
import 'package:open_bookshelf/services/book_database_service.dart';
import 'package:open_bookshelf/services/openlibrary_service.dart';

// Other
import 'package:open_bookshelf/i18n/translations.g.dart';
import 'package:open_bookshelf/layout.dart';
import 'package:open_bookshelf/services/settings_service.dart';
import 'package:open_bookshelf/theme.dart';

// Packages
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dynamic_color/dynamic_color.dart';

void main() async {
  try {
    // Flutter is initialized
    WidgetsFlutterBinding.ensureInitialized();

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

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) => DynamicColorBuilder(
        builder: (lightDynamic, darkDynamic) => MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => SideviewProvider()),
            ChangeNotifierProvider(create: (_) => BookshelfProvider()),
          ],
          builder: (context, child) => MaterialApp(
            locale: TranslationProvider.of(context).flutterLocale,
            supportedLocales: AppLocaleUtils.supportedLocales,
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            theme: customThemeData(lightDynamic, Brightness.light),
            darkTheme: customThemeData(darkDynamic, Brightness.dark),
            themeMode: ThemeMode.system,
            home: const Layout(),
          ),
        ),
      );
}

class FailedApplication extends StatelessWidget {
  const FailedApplication({required this.exception, super.key});

  final Object? exception;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: customThemeData(null, Brightness.dark),
      home: Scaffold(
        body: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.warning_rounded,
              color: fallbackPrimaryColor,
              size: 150.0,
            ),
            Text(
              exception.toString(),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
