import 'package:flutter/material.dart';
import 'package:open_bookshelf/i18n/translations.g.dart';
import 'package:open_bookshelf/screens/bookshelf/bookshelf_screen.dart';
import 'package:open_bookshelf/screens/tags/tags_screen.dart';
import 'package:open_bookshelf/screens/settings/settings_screen.dart';

/// Main layout destinations definition
class Destinations {
  final Icon icon;
  final String label;
  final Widget route;

  const Destinations({
    required this.icon,
    required this.label,
    required this.route,
  });

  static final routes = [
    Destinations(
      icon: const Icon(Icons.shelves),
      label: t.navigation.bookshelf,
      route: const BookshelfScreen(),
    ),
    Destinations(
      icon: const Icon(Icons.label),
      label: t.navigation.labels,
      route: const TagsScreen(),
    ),
    Destinations(
      icon: const Icon(Icons.settings),
      label: t.navigation.settings,
      route: const SettingsScreen(),
    ),
  ];
}

extension DestinationExtension on Iterable<Destinations> {
  /// Map every destination object to [NavigationDestination]
  Iterable<NavigationDestination> toNavigationDestinations() =>
      map((e) => NavigationDestination(icon: e.icon, label: e.label));

  /// Get every destination route's [Widget]
  Iterable<Widget> toRoutes() => map((e) => e.route);
}
