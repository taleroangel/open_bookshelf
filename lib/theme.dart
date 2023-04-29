import 'package:flutter/material.dart';

const primaryColor = Color(0xffd2ae88);

customThemeData(
  ColorScheme? colorScheme, [
  Brightness brightness = Brightness.light,
]) {
  final customColorScheme = colorScheme ??
      ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: brightness,
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: customColorScheme,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: customColorScheme.primary,
      unselectedItemColor: customColorScheme.onBackground,
    ),
    navigationDrawerTheme: NavigationDrawerThemeData(
      indicatorColor: customColorScheme.primary,
    ),
    navigationRailTheme: NavigationRailThemeData(
      indicatorColor: customColorScheme.primary,
      selectedIconTheme: IconThemeData(color: customColorScheme.onPrimary),
    ),
  );
}
