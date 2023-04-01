import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:open_bookshelf/i18n/translations.g.dart';
import 'package:open_bookshelf/main_layout.dart';
import 'package:open_bookshelf/providers/bookshelf_provider.dart';
import 'package:open_bookshelf/providers/sideview_provider.dart';
import 'package:open_bookshelf/services/bookshelf_service.dart';
import 'package:open_bookshelf/services/storage_service.dart';
import 'package:open_bookshelf/theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final locale = LocaleSettings.useDeviceLocale(); // Initialize Locale

  // GetIt register dependencies
  GetIt.I.registerSingleton(Logger(printer: PrettyPrinter()));
  GetIt.I.registerSingleton(StorageService());
  GetIt.I.registerSingleton(BookshelfService());
  GetIt.I.registerSingletonAsync(SharedPreferences.getInstance);

  // Set logging level
  Logger.level = kDebugMode ? Level.debug : Level.warning;

  // Make sure all paths exist
  await StorageService.ensurePathsExists();
  // Get all dependencies ready
  await GetIt.I.allReady();

  // Run the application
  runApp(TranslationProvider(child: const Application()));

  // Log information
  if (kDebugMode) {
    GetIt.I.get<Logger>().d('''Platform Settings were fetched!
Language: ${locale.languageCode}
Locale: ${Platform.localeName}
Platform: ${Platform.operatingSystem}
Logging Level: ${Logger.level}''');
  }
}

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
        builder: (lightDynamic, darkDynamic) => MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => SideviewProvider()),
                ChangeNotifierProvider(create: (_) => BookshelfProvider())
              ],
              builder: (_, __) => MaterialApp(
                debugShowCheckedModeBanner: false, // Obstruct actions
                locale: TranslationProvider.of(context).flutterLocale,
                supportedLocales: AppLocaleUtils.supportedLocales,
                localizationsDelegates: GlobalMaterialLocalizations.delegates,
                theme: customThemeData(lightDynamic, Brightness.light),
                darkTheme: customThemeData(darkDynamic, Brightness.dark),
                themeMode: ThemeMode.system,
                home: const MainLayout(),
              ),
            ));
  }
}
