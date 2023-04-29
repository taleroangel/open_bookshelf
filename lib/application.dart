import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:open_bookshelf/i18n/translations.g.dart';
import 'package:open_bookshelf/layout.dart';
import 'package:open_bookshelf/providers/bookshelf_provider.dart';
import 'package:open_bookshelf/providers/sideview_provider.dart';
import 'package:open_bookshelf/theme.dart';
import 'package:provider/provider.dart';

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
              color: primaryColor,
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
