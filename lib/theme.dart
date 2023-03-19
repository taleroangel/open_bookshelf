import 'package:flutter/material.dart';

customThemeData(ColorScheme? colorScheme,
    [Brightness brightness = Brightness.light]) {
  final customColorScheme = colorScheme ??
      ColorScheme.fromSeed(
          seedColor: const Color(0xFFC1B0A2), brightness: brightness);
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
          selectedIconTheme:
              IconThemeData(color: customColorScheme.onPrimary)));
}
