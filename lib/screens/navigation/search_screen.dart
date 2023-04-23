import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:open_bookshelf/i18n/translations.g.dart';
import 'package:open_bookshelf/models/book.dart';
import 'package:open_bookshelf/providers/bookshelf_provider.dart';
import 'package:open_bookshelf/widgets/book_pick_card_widget.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  /// Bookshelf provider
  late final BookshelfProvider bookshelfProvider;

  /// Book results to show
  Set<Book> bookResults = {};

  @override
  void initState() {
    // Add bookshelf provider
    SchedulerBinding.instance.addPostFrameCallback((_) {
      bookshelfProvider = context.read<BookshelfProvider>();
    });
    super.initState();
  }

  @override
  void dispose() {
    bookResults = {};
    super.dispose();
  }

  /// Prompted on [TextField] change
  void onSearch(String value) => setState(() {
        bookResults = value.isEmpty
            ? {} // If string is empty then show no results
            : bookshelfProvider.bookshelf.values
                .where((element) =>
                    searchStringParser(
                      element.title,
                    ) // Parsed title contains parsed value
                        .contains(searchStringParser(value)) ||
                    (element.subtitle != null &&
                        searchStringParser(element
                                .subtitle!) // Subtitle isn't null and parsed subtitle contains parsed value
                            .contains(searchStringParser(value))))
                .toSet();
      });

  String searchStringParser(String value) => value.toLowerCase();

  @override
  Widget build(BuildContext context) {
    final showBooks = bookResults
        .map((e) => BookPickCardWidget(
              book: e,
              onTap: (Book book) {
                bookshelfProvider.currentlySelectedBook = book;
                context.dispatchNotification(OnBookSelectionNotification());
              },
            ))
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(t.navigation.search)),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                label: Text(t.search.title),
              ),
              onChanged: onSearch,
            ),
          ),
          // Show book results
          bookResults.isEmpty
              ? Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_rounded,
                          size: 60.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 60,
                            vertical: 20,
                          ),
                          child: Text(
                            t.search.subtitle,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Expanded(
                  child: LayoutBuilder(
                    builder: (_, constraints) => SingleChildScrollView(
                      child: GridView.count(
                        shrinkWrap: true,
                        crossAxisCount:
                            constraints.maxWidth ~/ BookPickCardWidget.boxSize,
                        padding: const EdgeInsets.all(16.0),
                        childAspectRatio: BookPickCardWidget.boxAspectRatio,
                        mainAxisSpacing: 16.0,
                        children: showBooks,
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
