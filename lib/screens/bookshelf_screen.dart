import 'package:flutter/material.dart';
import 'package:open_bookshelf/i18n/translations.g.dart';
import 'package:open_bookshelf/models/book.dart';
import 'package:open_bookshelf/providers/bookshelf_provider.dart';
import 'package:open_bookshelf/widgets/book_pick_widget.dart';
import 'package:provider/provider.dart';

const _gridSpacing = 4.0;
const _boxSize = 160;
const _boxAspectRatio = 0.65;

class BookshelfScreen extends StatelessWidget {
  final BookCollection filter;
  const BookshelfScreen(this.filter, {super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BookshelfProvider>(
      builder: (context, provider, child) {
        // Take only books where collection is same as filter
        final bookshelf = provider.books.values
            .where((value) => (value.collection == filter))
            .map((e) => BookPickWidget(
                book: e,
                onTap: (book) {
                  provider.selectedBook = book;
                  context.dispatchNotification(OnBookSelectionNotification());
                }))
            .toList();

        return Scaffold(
            appBar: AppBar(title: Text(t.navigation.bookshelf)),
            body: bookshelf.isEmpty
                ? child
                : LayoutBuilder(
                    builder: (_, constraints) {
                      return GridView.count(
                          crossAxisCount: constraints.maxWidth ~/ _boxSize,
                          padding: const EdgeInsets.all(2 * _gridSpacing),
                          childAspectRatio: _boxAspectRatio,
                          mainAxisSpacing: 2 * _gridSpacing,
                          crossAxisSpacing: _gridSpacing,
                          children: bookshelf);
                    },
                  ));
      },
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Icon(Icons.report,
                  size: 60.0,
                  color: Theme.of(context)
                      .colorScheme
                      .onBackground
                      .withAlpha(200)),
            ),
            Text(
              t.bookshelf.no_books,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
