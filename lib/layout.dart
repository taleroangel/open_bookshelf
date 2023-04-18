import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:open_bookshelf/i18n/translations.g.dart';
import 'package:open_bookshelf/providers/bookshelf_provider.dart';
import 'package:open_bookshelf/providers/sideview_provider.dart';
import 'package:open_bookshelf/screens/other/add_book_screen.dart';
import 'package:open_bookshelf/screens/navigation/search_screen.dart';
import 'package:open_bookshelf/screens/navigation/settings_screen.dart';
import 'package:open_bookshelf/screens/other/book_screen.dart';
import 'package:open_bookshelf/screens/navigation/bookshelf_screen.dart';
import 'package:open_bookshelf/screens/navigation/labels_screen.dart';
import 'package:open_bookshelf/widgets/sideview_widget.dart';
import 'package:provider/provider.dart';

/// An adaptive layout in which the content (either [BookshelfScreen] or
/// [SettingsScreen]) is shown in a [PageView], and a [BookScreen] is either
/// shown in a side view controlled by [SideviewProvider] or pushed as
/// a new [MaterialPageRoute] depending on screen size
class Layout extends StatefulWidget {
  const Layout({
    super.key,
  });

  /// Pages to be shown in the [PageView]
  static const navigationItems = [
    BookshelfScreen(),
    LabelsScreen(),
    SearchScreen(),
    SettingsScreen()
  ];

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  final _pageController = PageController();
  int currentPageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sideviewProvider = context.read<SideviewProvider>();
    return AdaptiveScaffold(
      // Depending on screen size 'largeSecondaryBody' will either
      // build or dispose the provided widget, SideviewWidget alters state
      // inside SideviewProvider so actions can be taken when the sideview gets
      // enabled or disabled
      largeSecondaryBody: (_) => const SideviewWidget(child: BookScreen()),
      body: (_) =>
          // When a book is picked from BookScreen, it creates a OnBookSelectionNotification
          // that bubbles up until this point, if a Sideview is enabled then the book preview
          // should be shown there, else should be pushed as a new route
          NotificationListener<OnBookSelectionNotification>(
        onNotification: (notification) {
          // If sideview is disabled then push route
          // else do nothing since clicking a book automatically
          // sets it as the currentlySelectedBook in BookshelfProvider
          if (!sideviewProvider.sideviewAvailable) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const BookScreen(),
            ));
          }
          return true;
        },
        child: Scaffold(
          // Show an 'Add Book' button in all BookshelfScreens
          floatingActionButton: Layout.navigationItems[currentPageIndex]
                  is BookshelfScreen
              ? FloatingActionButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const AddBookScreen(),
                      )),
                  child: const Icon(Icons.add))
              : null,
          // Show a page view with the routes
          body: PageView(
            controller: _pageController,
            scrollDirection: Axis.horizontal,
            onPageChanged: (selectedIndex) => setState(() {
              currentPageIndex = selectedIndex;
            }),
            children: Layout.navigationItems,
          ),
        ),
      ),
      selectedIndex: currentPageIndex,
      onSelectedIndexChange: (selectedIndex) => setState(() {
        // When the SettingsScreen is prompted then it should forget
        // the currently selected book, this is because deleting the database
        // or the images in caches may alter this data while in use
        if (Layout.navigationItems[selectedIndex] is SettingsScreen) {
          context.read<BookshelfProvider>().currentlySelectedBook = null;
        }
        // Change the index
        currentPageIndex = selectedIndex;
        // Animate transition to page
        _pageController.animateToPage(currentPageIndex,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }),
      destinations: [
        NavigationDestination(
            icon: const Icon(Icons.shelves), label: t.navigation.bookshelf),
        NavigationDestination(
            icon: const Icon(Icons.label), label: t.navigation.labels),
        NavigationDestination(
            icon: const Icon(Icons.search), label: t.navigation.search),
        NavigationDestination(
            icon: const Icon(Icons.settings), label: t.navigation.settings),
      ],
    );
  }
}
