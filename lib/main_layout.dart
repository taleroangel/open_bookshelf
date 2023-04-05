import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:open_bookshelf/i18n/translations.g.dart';
import 'package:open_bookshelf/models/book.dart';
import 'package:open_bookshelf/providers/bookshelf_provider.dart';
import 'package:open_bookshelf/providers/sideview_provider.dart';
import 'package:open_bookshelf/screens/add_book_screen.dart';
import 'package:open_bookshelf/screens/settings_screen.dart';
import 'package:open_bookshelf/screens/book_screen.dart';
import 'package:open_bookshelf/screens/bookshelf_screen.dart';
import 'package:open_bookshelf/widgets/sideview_widget.dart';
import 'package:provider/provider.dart';

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
    final sideviewProvider = context.read<SideviewProvider>();

    return AdaptiveScaffold(
      largeSecondaryBody: (_) => const SideviewWidget(child: BookScreen()),
      body: (_) => NotificationListener<OnBookSelectionNotification>(
        onNotification: (notification) {
          if (!sideviewProvider.sideviewAvailable) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const BookScreen(),
            ));
          }
          return true;
        },
        child: Scaffold(
          floatingActionButton: _currentIndex < 4
              ? FloatingActionButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const AddBookScreen(),
                      )),
                  child: const Icon(Icons.add))
              : null,
          body: PageView(
            controller: _pageController,
            scrollDirection: Axis.horizontal,
            onPageChanged: (selectedIndex) => setState(() {
              _currentIndex = selectedIndex;
            }),
            children: const [
              BookshelfScreen(),
              BookshelfScreen(filter: BookCollection.reading),
              BookshelfScreen(filter: BookCollection.wishlist),
              BookshelfScreen(filter: BookCollection.read),
              SettingsScreen()
            ],
          ),
        ),
      ),
      selectedIndex: _currentIndex,
      onSelectedIndexChange: (selectedIndex) => setState(() {
        _currentIndex = selectedIndex;
        _pageController.animateToPage(_currentIndex,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }),
      destinations: [
        NavigationDestination(
            icon: const Icon(Icons.shelves), label: t.navigation.bookshelf),
        NavigationDestination(
            icon: const Icon(Icons.auto_stories), label: t.navigation.reading),
        NavigationDestination(
            icon: const Icon(Icons.lightbulb_sharp),
            label: t.navigation.wishlist),
        NavigationDestination(
            icon: const Icon(Icons.book), label: t.navigation.read),
        NavigationDestination(
            icon: const Icon(Icons.settings), label: t.navigation.settings),
      ],
    );
  }
}
