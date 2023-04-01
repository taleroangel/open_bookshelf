import 'package:flutter/material.dart';
import 'package:open_bookshelf/models/book.dart';
import 'package:open_bookshelf/providers/bookshelf_provider.dart';
import 'package:open_bookshelf/i18n/translations.g.dart';
import 'package:open_bookshelf/widgets/text_with_icon_widget.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/book_cover_widget.dart';

class BookScreen extends StatelessWidget {
  const BookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookshelfProvider = context.watch<BookshelfProvider>();
    final Book? book = bookshelfProvider.selectedBook;

    return book == null
        // Empty scaffold for null books
        ? Scaffold(
            body: Center(
                child: Text(
              t.preview.not_selected,
              style: Theme.of(context).textTheme.headlineLarge,
            )),
          )
        // Book details
        : Scaffold(
            appBar: AppBar(
              title: Text(book.title),
              actions: [
                if (book.url != null)
                  IconButton(
                      onPressed: () {
                        launchUrl(
                                mode: LaunchMode.externalApplication,
                                Uri.parse(book.url!))
                            .onError((error, stackTrace) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("URL: ${book.url}\nError:$error")));
                          return true;
                        });
                      },
                      icon: const Icon(Icons.public))
              ],
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 18.0),
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: SegmentedButton<BookCollection>(
                      segments: BookCollection.values
                          .map((e) => ButtonSegment<BookCollection>(
                              value: e,
                              icon: Icon(e.icon),
                              label: Text(BookCollection.getLabel(e))))
                          .toList(),
                      selected: {book.collection},
                      onSelectionChanged: (collection) => bookshelfProvider
                          .updateBookCollection(collection.first),
                    ),
                  ),

                  // Show Cover
                  Expanded(
                      child: Stack(
                    alignment: Alignment.center,
                    children: const [BookCoverWidget()],
                  )),

                  // Show title
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      book.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const Divider(height: 16.0),

                  // Show ISBN
                  TextWithIconWidget(
                    icon: Icons.qr_code_2_rounded,
                    text: "ISBN: ${book.isbn}",
                  ),

                  // Show Publishers
                  if (book.publishers.isNotEmpty)
                    TextWithIconWidget(
                        icon: Icons.storefront_rounded,
                        text: book.publishers
                            .reduce((value, element) => "$value, $element")),

                  // Show authors
                  if (book.authors.isNotEmpty)
                    TextWithIconWidget(
                        icon: Icons.people,
                        text: book.authors
                            .reduce((value, element) => "$value, $element")),

                  // Show subjects
                  if (book.subjects.isNotEmpty)
                    TextWithIconWidget(
                        icon: Icons.sell_rounded,
                        text: book.subjects
                            .reduce((value, element) => "$value, $element")),
                ]),
              ),
            ),
          );
  }
}
