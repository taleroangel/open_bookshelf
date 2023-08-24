import 'package:flutter/material.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:open_bookshelf/providers/bookshelf_provider.dart';
import 'package:open_bookshelf/screens/book/book_screen.dart';
import 'package:open_bookshelf/widgets/book_pick_card_widget.dart';
import 'package:provider/provider.dart';

const _gridSpacing = 4.0;

class BookSearchDelegate extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) => null;

  @override
  Widget? buildLeading(BuildContext context) => null;

  @override
  Widget buildResults(BuildContext context) {
    final provider = context.watch<IBookshelfProvider>();

    return LayoutBuilder(
      builder: (_, constraints) => GridView.count(
        crossAxisCount: constraints.maxWidth ~/ BookPickCardWidget.boxSize,
        padding: const EdgeInsets.all(3 * _gridSpacing),
        childAspectRatio: BookPickCardWidget.boxAspectRatio,
        mainAxisSpacing: 2 * _gridSpacing,
        crossAxisSpacing: _gridSpacing,
        children: (provider.books.toList()
              ..sort(
                (a, b) => (tokenSetPartialRatio(b.title, query) -
                    tokenSetPartialRatio(a.title, query)),
              ))
            .where((element) => tokenSetPartialRatio(element.title, query) > 50)
            .map((e) => BookPickCardWidget(
                  key: ObjectKey(e),
                  book: e,
                  onTap: (book) {
                    // Set selected book as current book
                    provider.selectedBook = book;
                    // Push book information
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const BookScreen(),
                    ));
                  },
                ))
            .toList(),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final provider = context.watch<IBookshelfProvider>();

    return LayoutBuilder(
      builder: (_, constraints) => GridView.count(
        crossAxisCount: constraints.maxWidth ~/ BookPickCardWidget.boxSize,
        padding: const EdgeInsets.all(3 * _gridSpacing),
        childAspectRatio: BookPickCardWidget.boxAspectRatio,
        mainAxisSpacing: 2 * _gridSpacing,
        crossAxisSpacing: _gridSpacing,
        children: provider.books
            .map((e) => BookPickCardWidget(
                  key: ObjectKey(e),
                  book: e,
                  onTap: (book) {
                    // Set selected book as current book
                    provider.selectedBook = book;
                    // Push book information
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const BookScreen(),
                    ));
                  },
                ))
            .toList(),
      ),
    );
  }
}
