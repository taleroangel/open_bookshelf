import 'package:flutter/material.dart';

import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:provider/provider.dart';

import 'package:open_bookshelf/providers/bookshelf_provider.dart';
import 'package:open_bookshelf/providers/sideview_provider.dart';
import 'package:open_bookshelf/screens/book/book_screen.dart';
import 'package:open_bookshelf/screens/bookshelf/bookshelf_screen.dart';
import 'package:open_bookshelf/screens/destinations.dart';
import 'package:open_bookshelf/screens/settings/settings_screen.dart';
import 'package:open_bookshelf/widgets/book_pick_card_widget.dart';
import 'package:open_bookshelf/widgets/sideview_wrapper.dart';

/// An adaptive layout in which the content (either [BookshelfScreen] or
/// [SettingsScreen]) is shown in a [PageView], and a [BookScreen] is either
/// shown in a side view controlled by [SideviewProvider] or pushed as
/// a new [MaterialPageRoute] depending on screen size
class Layout extends StatefulWidget {
  const Layout({
    super.key,
  });

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
      largeSecondaryBody: (_) => const SideviewWrapper(child: BookScreen()),
      body: (_) =>
          // When a book is picked from BookScreen, it creates a OnBookSelectionNotification
          // that bubbles up until this point, if a Sideview is enabled then the book preview
          // should be shown there, else should be pushed as a new route
          NotificationListener<OnBookSelectionNotification>(
        onNotification: (notification) {
          // If sideview is disabled then push route
          // else do nothing since clicking a book automatically
          // sets it as the selectedBook in BookshelfProvider
          if (!sideviewProvider.sideviewAvailable) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const BookScreen(),
            ));
          }

          return true;
        },
        child: Scaffold(
          // Show a page view with the routes
          body: PageView(
            controller: _pageController,
            scrollDirection: Axis.horizontal,
            children: Destinations.routes.toRoutes().toList(),
            onPageChanged: (selectedIndex) => setState(() {
              currentPageIndex = selectedIndex;
            }),
          ),
        ),
      ),
      selectedIndex: currentPageIndex,
      onSelectedIndexChange: (selectedIndex) => setState(() {
        // When any screen different to BookshelfScreen is prompted
        // BookshelfProvider must forget the currently selected book,
        // this is because deleting the database  or the images in caches may
        // alter this data while in use
        if (Destinations.routes.elementAt(currentPageIndex).route
            is! BookshelfScreen) {
          context.read<IBookshelfProvider>().selectedBook = null;
        }
        // Change the index
        currentPageIndex = selectedIndex;
        // Animate transition to page
        _pageController.animateToPage(
          currentPageIndex,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }),

      // Bottom navigation bar destinations
      destinations: Destinations.routes.toNavigationDestinations().toList(),
    );
  }
}
