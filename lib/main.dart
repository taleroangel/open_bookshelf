import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:open_bookshelf/i18n/translations.g.dart';

import 'package:open_bookshelf/screens/about_screen.dart';
import 'package:open_bookshelf/screens/bookshelf_screen.dart';
import 'package:open_bookshelf/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final locale = LocaleSettings.useDeviceLocale(); // Initialize Locale

  // GetIt register dependencies
  GetIt.I.registerSingleton(Logger(printer: PrettyPrinter()));
  GetIt.I.registerSingletonAsync(SharedPreferences.getInstance);

  // Set logging level
  Logger.level = kDebugMode ? Level.debug : Level.warning;

  // Run the application
  await GetIt.I.allReady(); //TODO Loading screen
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
      builder: (lightDynamic, darkDynamic) => MaterialApp(
        locale: TranslationProvider.of(context).flutterLocale,
        supportedLocales: AppLocaleUtils.supportedLocales,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: customThemeData(null, Brightness.light),
        //darkTheme: customThemeData(darkDynamic, Brightness.dark),
        themeMode: ThemeMode.system,
        home: const MainLayout(),
      ),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({
    super.key,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      body: (_) => PageView(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        onPageChanged: (selectedIndex) => setState(() {
          _currentIndex = selectedIndex;
        }),
        children: const [
          BookshelfScreen(BookshelfFilter.reading),
          BookshelfScreen(BookshelfFilter.wishlist),
          BookshelfScreen(BookshelfFilter.read),
          BookshelfScreen(BookshelfFilter.favorites),
          AboutScreen()
        ],
      ),
      selectedIndex: _currentIndex,
      onSelectedIndexChange: (selectedIndex) => setState(() {
        _currentIndex = selectedIndex;
        _pageController.animateToPage(_currentIndex,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }),
      destinations: [
        NavigationDestination(
            icon: const Icon(Icons.menu_book_rounded),
            label: t.navigation.reading),
        NavigationDestination(
            icon: const Icon(Icons.lightbulb_sharp),
            label: t.navigation.wishlist),
        NavigationDestination(
            icon: const Icon(Icons.book), label: t.navigation.read),
        NavigationDestination(
            icon: const Icon(Icons.favorite), label: t.navigation.favorites),
        NavigationDestination(
            icon: const Icon(Icons.help), label: t.navigation.about),
      ],
    );
  }
}
