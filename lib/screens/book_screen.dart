import 'package:flutter/material.dart';
import 'package:open_bookshelf/models/book.dart';
import 'package:open_bookshelf/providers/bookshelf_provider.dart';
import 'package:open_bookshelf/screens/cover_screen.dart';
import 'package:open_bookshelf/i18n/translations.g.dart';
import 'package:provider/provider.dart';

class BookScreen extends StatelessWidget {
  final Book? book;
  const BookScreen({this.book, super.key});

  @override
  Widget build(BuildContext context) {
    final bookshelfService = context.watch<BookshelfProvider>().service;
    return book == null
        ? Scaffold(
            body: Center(
                child: Text(
              t.preview.not_selected,
              style: Theme.of(context).textTheme.headlineLarge,
            )),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text(book!.title),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(children: [
                  // Show Cover
                  FutureBuilder(
                      future: bookshelfService.fetchCover(book!.cover),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          final image = Image.memory(snapshot.data!);
                          return Expanded(
                            child: Hero(
                              tag: "cover:zoom",
                              child: GestureDetector(
                                onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            CoverScreen(child: image))),
                                child: image,
                              ),
                            ),
                          );
                        } else {
                          return const CircularProgressIndicator();
                        }
                      }),

                  // Show ISBN
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "ISBN: ${book!.isbn}",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),

                  // Show title
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      book!.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Show Publishers
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 3.0, horizontal: 16.0),
                        child: Icon(Icons.corporate_fare_rounded,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                      Flexible(
                        child: Text(
                          book!.publishers
                              .reduce((value, element) => "$value, $element"),
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                      )
                    ],
                  ),
                  // Show authors
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 3.0, horizontal: 16.0),
                        child: Icon(Icons.people,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                      Flexible(
                        child: Text(
                          book!.authors
                              .reduce((value, element) => "$value, $element"),
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                      )
                    ],
                  ),

                  if (book!.description == null)
                    const SizedBox(
                      height: 16.0,
                    ),

                  // Show description
                  if (book!.description != null)
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        margin: const EdgeInsets.all(8.0),
                        child: SingleChildScrollView(
                            child: Text(book!.description!)),
                      ),
                    ),
                ]),
              ),
            ),
          );
  }
}
