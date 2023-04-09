import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_bookshelf/constants/endpoints.dart';
import 'package:open_bookshelf/models/book.dart';
import 'package:open_bookshelf/providers/bookshelf_provider.dart';
import 'package:open_bookshelf/i18n/translations.g.dart';
import 'package:open_bookshelf/widgets/text_with_icon_widget.dart';
import 'package:open_bookshelf/widgets/book_cover_widget.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class BookScreen extends StatelessWidget {
  /// Displays a book provided by [BookshelfProvider], if 'useThisBookInstead' parameter is non-null,
  /// that book is asumed not to be present in database and [BookshelfProvided will be ignored]
  const BookScreen(
      {this.useThisBookInstead, this.floatingActionButton, super.key});

  final Book? useThisBookInstead;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Consumer<BookshelfProvider>(
        child: Scaffold(
          body: Center(
              child: Text(
            t.book.not_selected,
            style: Theme.of(context).textTheme.headlineLarge,
          )),
        ),
        builder: (context, bookshelfProvider, child) {
          // Book currently selectted
          final Book? book =
              useThisBookInstead ?? bookshelfProvider.selectedBook;
          return book == null
              // Empty scaffold for null books
              ? child!
              // Book details
              : Scaffold(
                  appBar: AppBar(
                    title: Text(book.title),
                    actions: [
                      if (useThisBookInstead == null) const _DeleteBookButton(),
                      _PopupMenu(book)
                    ],
                  ),
                  floatingActionButton: floatingActionButton,
                  body: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 18.0),
                      child: Column(children: [
                        // Collection detector
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: StatefulBuilder(
                            builder: (context, setState) =>
                                SegmentedButton<BookCollection>(
                              segments: BookCollection.values
                                  .map((e) => ButtonSegment<BookCollection>(
                                      value: e,
                                      icon: Icon(e.icon),
                                      label: Text(BookCollection.getLabel(e))))
                                  .toList(),
                              selected: {book.collection},
                              onSelectionChanged: (collection) {
                                if (useThisBookInstead == null) {
                                  bookshelfProvider
                                      .updateBookCollection(collection.first);
                                } else {
                                  setState(() {
                                    book.collection = collection.first;
                                  });
                                }
                              },
                            ),
                          ),
                        ),

                        // Show Cover
                        Expanded(
                            child: BookCoverWidget(
                          selectedBook: useThisBookInstead,
                        )),

                        // Show title
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(children: [
                              TextSpan(
                                text: book.title,
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              if (book.url == null)
                                TextSpan(
                                  text: "\n${t.book.not_int_openlibrary}",
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                )
                            ]),
                          ),
                        ),

                        const Divider(height: 16.0),

                        // Show ISBN
                        GestureDetector(
                          onTap: () =>
                              Clipboard.setData(ClipboardData(text: book.isbn))
                                  .then((value) => ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                          content: Text(
                                              t.navigation.copied_clipboard)))),
                          child: TextWithIconWidget(
                            icon: Icons.qr_code_2_rounded,
                            text: "ISBN: ${book.isbn}",
                          ),
                        ),

                        // Show Publishers
                        if (book.publishers.isNotEmpty)
                          TextWithIconWidget(
                              icon: Icons.storefront_rounded,
                              text: book.publishers.reduce(
                                  (value, element) => "$value, $element")),

                        // Show authors
                        if (book.authors.isNotEmpty)
                          TextWithIconWidget(
                              icon: Icons.people,
                              text: book.authors.reduce(
                                  (value, element) => "$value, $element")),

                        // Show subjects
                        if (book.subjects.isNotEmpty)
                          TextWithIconWidget(
                              icon: Icons.sell_rounded,
                              text: book.subjects.reduce(
                                  (value, element) => "$value, $element")),
                      ]),
                    ),
                  ),
                );
        });
  }
}

class _DeleteBookButton extends StatelessWidget {
  const _DeleteBookButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    content: Text(t.book.delete.confirm),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(t.navigation.cancel_button)),
                      TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text(
                            t.navigation.delete_button,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error),
                          )),
                    ],
                  )).then((userConfirmed) {
            if (userConfirmed) {
              context.read<BookshelfProvider>().deleteCurrentBook().then(
                  (bookDeleteResult) => ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(
                          content: Text(bookDeleteResult
                              ? t.book.delete.success
                              : t.book.delete.failure))));
            }
          });
        },
        icon: Icon(
          Icons.delete,
          color: Theme.of(context).colorScheme.error,
        ));
  }
}

class _PopupMenu extends StatelessWidget {
  const _PopupMenu(this.book);

  final Book book;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      onSelected: (value) {
        switch (value) {
          case -1:
            showDialog(
                context: context,
                builder: (context) => const _ContributeAlertDialog());
            break;
          case 0:
            showDialog(
              context: context,
              builder: (context) => _BarcodePreviewAlertDialog(book.isbn),
            );
            break;
          case 1:
            launchUrl(
                    mode: LaunchMode.externalApplication, Uri.parse(book.url!))
                .onError((error, stackTrace) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("URL: ${book.url}\nError:$error")));
              return true;
            });
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 0,
          child: Row(children: [
            const Padding(
              padding: EdgeInsets.only(right: 12.0),
              child: Icon(Icons.barcode_reader),
            ),
            Text(t.book.submenu.barcode_item)
          ]),
        ),
        PopupMenuItem(
          enabled: book.url != null,
          value: 1,
          child: Row(children: [
            const Padding(
              padding: EdgeInsets.only(right: 12.0),
              child: Icon(Icons.public),
            ),
            Text(t.book.submenu.visit_on_openlibrary)
          ]),
        ),
        if (book.url == null)
          PopupMenuItem(
            value: -1,
            child: Row(children: [
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Icon(
                  Icons.favorite,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Text(
                t.book.submenu.contribute_on_openlibrary,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              )
            ]),
          ),
      ],
    );
  }
}

class _ContributeAlertDialog extends StatelessWidget {
  const _ContributeAlertDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(t.book.contribute.title),
      content: SizedBox(
        width: 350,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              t.book.contribute.summary,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(
              height: 8.0,
            ),
            Text(t.book.contribute.what_is_openlibrary),
            const SizedBox(
              height: 8.0,
            ),
            Text(t.book.contribute.why_contribute)
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: Navigator.of(context).pop,
            child: Text(t.book.contribute.skip)),
        TextButton.icon(
          onPressed: () {
            launchUrl(
                    mode: LaunchMode.externalApplication,
                    Uri.parse(openLibrary['contribute']!))
                .onError((error, stackTrace) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content:
                      Text("URL: ${openLibrary['contribute']}\nError:$error")));
              return true;
            });
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.favorite),
          label: Text(t.book.contribute.contribute),
          style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              backgroundColor: Theme.of(context).colorScheme.primary),
        ),
      ],
    );
  }
}

class _BarcodePreviewAlertDialog extends StatelessWidget {
  const _BarcodePreviewAlertDialog(this.isbn);

  final String isbn;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(t.book.barcode.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 350, child: Text(t.book.barcode.description)),
          BarcodeWidget(
            data: isbn,
            backgroundColor: Colors.transparent,
            color: Theme.of(context).colorScheme.onBackground,
            barcode: Barcode.isbn(),
            padding: const EdgeInsets.all(32.0),
            errorBuilder: (context, error) => RichText(
                textAlign: TextAlign.center,
                text: TextSpan(children: [
                  TextSpan(
                      text: t.errors.failed_barcode,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error)),
                  TextSpan(
                    text: "\nISBN $isbn",
                    style: Theme.of(context).textTheme.bodyLarge,
                  )
                ])),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: Navigator.of(context).pop,
            child: Text(t.navigation.ok_button))
      ],
    );
  }
}
