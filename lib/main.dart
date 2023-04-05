import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:logger/logger.dart';
import 'package:open_bookshelf/i18n/translations.g.dart';
import 'package:open_bookshelf/main_layout.dart';
import 'package:open_bookshelf/providers/bookshelf_provider.dart';
import 'package:open_bookshelf/providers/sideview_provider.dart';
import 'package:open_bookshelf/services/cache_storage_service.dart';
import 'package:open_bookshelf/services/book_database_service.dart';
import 'package:open_bookshelf/theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  // Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Locale
  LocaleSettings.useDeviceLocale();

  // Initialize Hive database
  await Hive.initFlutter((await getApplicationSupportDirectory()).path);

  // Logger
  GetIt.I.registerSingleton(Logger(
      printer: PrettyPrinter(),
      level: kDebugMode ? Level.debug : Level.warning));

  // GetIt register async dependencies
  GetIt.I.registerSingletonAsync(CacheStorageService.getInstance);
  GetIt.I.registerSingletonAsync(BookDatabaseService.getInstance);
  GetIt.I.registerSingletonAsync(SharedPreferences.getInstance);

  // Get all dependencies ready
  await GetIt.I.allReady();

  // Run the application
  runApp(TranslationProvider(child: const Application()));
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
