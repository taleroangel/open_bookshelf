import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:open_bookshelf/i18n/translations.g.dart';
import 'package:open_bookshelf/models/book.dart';
import 'package:open_bookshelf/screens/about_screen.dart';
import 'package:open_bookshelf/screens/bookshelf_screen.dart';
import 'package:open_bookshelf/widgets/book_preview_sideview.dart';

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
      largeSecondaryBody: (_) => const BookPreviewSideview(),
      body: (_) => PageView(
        controller: _pageController,
        scrollDirection:
            MediaQuery.of(context).orientation == Orientation.landscape
                ? Axis.vertical
                : Axis.horizontal,
        onPageChanged: (selectedIndex) => setState(() {
          _currentIndex = selectedIndex;
        }),
        children: const [
          BookshelfScreen(BookCollection.reading),
          BookshelfScreen(BookCollection.wishlist),
          BookshelfScreen(BookCollection.read),
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
            icon: const Icon(Icons.help), label: t.navigation.about),
      ],
    );
  }
}
