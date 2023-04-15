import 'package:flutter/material.dart';
import 'package:open_bookshelf/i18n/translations.g.dart';
import 'package:open_bookshelf/models/book.dart';
import 'package:open_bookshelf/providers/bookshelf_provider.dart';
import 'package:open_bookshelf/widgets/book_pick_widget.dart';
import 'package:open_bookshelf/widgets/collection_picker_widget.dart';
import 'package:provider/provider.dart';

const _gridSpacing = 4.0;
const _boxSize = 160;
const _boxAspectRatio = 0.65;

/// Widget to show a list of [Book] stored in the Bookshelf
class BookshelfScreen extends StatelessWidget {
  const BookshelfScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var filter = BookCollection.none;

    return Scaffold(
      appBar: AppBar(title: Text(t.navigation.bookshelf)),
      body: StatefulBuilder(
        builder: (context, setState) {
          final provider = context.watch<BookshelfProvider>();
          // Filter bookshelf by collection
          final bookshelf = provider.bookshelf.values
              .filterBooksByCollection(filter)
              // wrap books into a BookPickWidget
              .map((e) => BookPickWidget(
                  book: e,
                  onTap: (book) {
                    // Set selected book as current book
                    provider.currentlySelectedBook = book;
                    // Dispatch book selection notification
                    context.dispatchNotification(OnBookSelectionNotification());
                  }))
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
                                    child: Icon(Icons.new_releases_rounded,
                                        size: 50.0,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground
                                            .withAlpha(200)),
                                  ),
                                  Text(
                                    t.bookshelf.no_books,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : LayoutBuilder(
                              builder: (_, constraints) {
                                return GridView.count(
                                    crossAxisCount:
                                        constraints.maxWidth ~/ _boxSize,
                                    padding:
                                        const EdgeInsets.all(2 * _gridSpacing),
                                    childAspectRatio: _boxAspectRatio,
                                    mainAxisSpacing: 2 * _gridSpacing,
                                    crossAxisSpacing: _gridSpacing,
                                    children: bookshelf);
                              },
                            ))
            ],
          );
        },
      ),
    );
  }
}
