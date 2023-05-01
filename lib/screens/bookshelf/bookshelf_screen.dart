import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:open_bookshelf/i18n/translations.g.dart';
import 'package:open_bookshelf/models/book.dart';
import 'package:open_bookshelf/providers/bookshelf_provider.dart';
import 'package:open_bookshelf/screens/bookshelf/add_book_screen.dart';
import 'package:open_bookshelf/widgets/book_pick_card_widget.dart';
import 'package:open_bookshelf/widgets/collection_picker_widget.dart';

const _gridSpacing = 4.0;

/// Widget to show a list of [Book] stored in the Bookshelf
class BookshelfScreen extends StatelessWidget {
  const BookshelfScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Current book filter
    var filter = BookCollection.none;

    return Scaffold(
      appBar: AppBar(title: Text(t.navigation.bookshelf)),
      // Add book button
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const AddBookScreen(),
        )),
        child: const Icon(Icons.add),
      ),
      body: StatefulBuilder(
        builder: (context, setState) {
          // Watch for bookshelf contents
          final provider = context.watch<IBookshelfProvider>();

          // Filter bookshelf by collection
          final bookshelf = provider.books
              .filterBooksByCollection(filter)
              // wrap books into a BookPickWidget
              .map((e) => BookPickCardWidget(
                    key: ObjectKey(e),
                    book: e,
                    onTap: (book) {
                      // Set selected book as current book
                      provider.selectedBook = book;
                      // Dispatch book selection notification
                      context.dispatchNotification(
                        OnBookSelectionNotification(),
                      );
                    },
                  ))
              .toList();

          // Create layout as a grid of books
          return Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              // Show picker
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CollectionPickerWidget(
                  initialValue: filter,
                  onSelect: (value) => setState(() {
                    filter = value;
                  }),
                ),
              ),
              Expanded(
                child: // Show Grid
                    bookshelf.isEmpty
                        ? Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Icon(
                                    Icons.new_releases_rounded,
                                    size: 50.0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground
                                        .withAlpha(200),
                                  ),
                                ),
                                Text(
                                  t.bookshelf.no_books,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : LayoutBuilder(
                            builder: (_, constraints) => GridView.count(
                              crossAxisCount: constraints.maxWidth ~/
                                  BookPickCardWidget.boxSize,
                              padding: const EdgeInsets.all(2 * _gridSpacing),
                              childAspectRatio:
                                  BookPickCardWidget.boxAspectRatio,
                              mainAxisSpacing: 2 * _gridSpacing,
                              crossAxisSpacing: _gridSpacing,
                              children: bookshelf,
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}
