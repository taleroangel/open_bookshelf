import 'package:flutter/material.dart';

const primaryColor = Color(0xFFC1B0A2);

customThemeData(ColorScheme? colorScheme,
        [Brightness brightness = Brightness.light]) =>
    ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme ??
            ColorScheme.fromSeed(
                seedColor: primaryColor, brightness: brightness));
