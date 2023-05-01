import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:open_bookshelf/i18n/translations.g.dart';
import 'package:open_bookshelf/screens/layout.dart';
import 'package:open_bookshelf/theme.dart';

/// Initialize application with Theme
class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) => DynamicColorBuilder(
        builder: (lightDynamic, darkDynamic) => MaterialApp(
          locale: TranslationProvider.of(context).flutterLocale,
          supportedLocales: AppLocaleUtils.supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          theme: customThemeData(lightDynamic, Brightness.light),
          darkTheme: customThemeData(darkDynamic, Brightness.dark),
          themeMode: ThemeMode.system,
          home: const Layout(),
        ),
      );
}

/// Show on application initialization failure
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
              color: openBookshelfPrimaryColor,
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
