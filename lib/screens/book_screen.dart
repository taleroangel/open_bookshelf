import 'package:flutter/material.dart';
import 'package:open_bookshelf/models/book.dart';
import 'package:open_bookshelf/providers/bookshelf_provider.dart';
import 'package:open_bookshelf/screens/cover_screen.dart';
import 'package:open_bookshelf/i18n/translations.g.dart';
import 'package:open_bookshelf/services/bookshelf_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class BookScreen extends StatelessWidget {
  final String? bookISBN;
  const BookScreen({this.bookISBN, super.key});

  @override
  Widget build(BuildContext context) {
    final bookshelfProvider = context.watch<BookshelfProvider>();
    final bookshelfService = bookshelfProvider.service;

    final Book? book = bookshelfProvider.getBookByISBN(bookISBN);

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
                      onSelectionChanged: (collection) =>
                          bookshelfProvider.updateBook(
                              book.copyWith(collection: collection.first)),
                    ),
                  ),

                  // Show Cover
                  _BookImage(bookshelfService: bookshelfService, book: book),

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
                  _InlineDetails(
                    icon: Icons.qr_code_2_rounded,
                    text: "ISBN: ${book.isbn}",
                  ),

                  // Show Publishers
                  if (book.publishers.isNotEmpty)
                    _InlineDetails(
                        icon: Icons.storefront_rounded,
                        text: book.publishers
                            .reduce((value, element) => "$value, $element")),

                  // Show authors
                  if (book.authors.isNotEmpty)
                    _InlineDetails(
                        icon: Icons.people,
                        text: book.authors
                            .reduce((value, element) => "$value, $element")),

                  // Show subjects
                  if (book.subjects.isNotEmpty)
                    _InlineDetails(
                        icon: Icons.sell_rounded,
                        text: book.subjects
                            .reduce((value, element) => "$value, $element")),
                ]),
              ),
            ),
          );
  }
}

class _BookImage extends StatelessWidget {
  const _BookImage({
    required this.bookshelfService,
    required this.book,
  });

  final BookshelfService bookshelfService;
  final Book? book;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: bookshelfService.fetchCover(book!.cover),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final image = Image.memory(snapshot.data!);
            return Expanded(
              child: Hero(
                tag: "cover:zoom",
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => CoverScreen(child: image))),
                  child: image,
                ),
              ),
            );
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}

class _InlineDetails extends StatelessWidget {
  const _InlineDetails({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 16.0),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
        )
      ],
    );
  }
}
