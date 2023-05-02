import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:open_bookshelf/i18n/translations.g.dart';
import 'package:open_bookshelf/models/book.dart';
import 'package:open_bookshelf/providers/bookshelf_provider.dart';
import 'package:open_bookshelf/screens/book/barcode_preview_dialog.dart';
import 'package:open_bookshelf/screens/book/contribute_alert_dialog.dart';
import 'package:open_bookshelf/screens/book/delete_book_button.dart';
import 'package:open_bookshelf/widgets/book_cover_widget.dart';
import 'package:open_bookshelf/widgets/collection_picker_widget.dart';
import 'package:open_bookshelf/widgets/tag_picker_widget.dart';
import 'package:open_bookshelf/widgets/text_with_icon_widget.dart';

/// Displays a book provided by [IBookshelfProvider], if 'useThisBookInstead' parameter is non-null,
/// that book is asumed not to be present in database and [BookshelfProvided will be ignored], instead
/// changes will be made directly to provided book and database functionality is disabled
class BookScreen extends StatelessWidget {
  const BookScreen({
    this.useThisBookInstead,
    this.floatingActionButton,
    super.key,
  });

  final Book? useThisBookInstead;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    // Read the context
    final bookshelfProvider = context.watch<IBookshelfProvider>();

    // Book currently selected, either provided via parameter or present in database
    Book? book = useThisBookInstead ?? bookshelfProvider.selectedBook;

    // If no book is selected
    return book == null
        // Empty scaffold for null books
        ? Scaffold(
            body: Center(
              child: Text(
                t.book.not_selected,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
          )
        // Book details
        : Scaffold(
            appBar: AppBar(
              title: Text(book.title),
              actions: [
                // If book is present in database then deletion is possible
                if (useThisBookInstead == null) const DeleteBookButton(),
                // Show an action menu
                _PopupMenu(book),
              ],
            ),
            floatingActionButton: floatingActionButton,
            body: Padding(
              padding: const EdgeInsets.only(bottom: 18.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  // Collection picker
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: CollectionPickerWidget(
                      key: ObjectKey(book),
                      initialValue: book.collection,
                      onSelect: (value) {
                        // Alter book
                        book = book!.copyWith(
                          collection: value,
                        );
                        // Use the provider
                        if (useThisBookInstead == null) {
                          bookshelfProvider[book!.isbn] = book;
                        }
                      },
                    ),
                  ),

                  // Show Cover
                  Expanded(
                    flex: 6,
                    child: BookCoverWidget(
                      useThisBookInstead: useThisBookInstead,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Show title
                        Text(
                          book!.title,
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                        ),

                        if (book!.subtitle != null)
                          Text(
                            "\n${book!.subtitle}",
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                          ),

                        if (book!.url == null)
                          Text(
                            "\n${t.book.not_in_openlibrary}",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16.0),

                  // Show ISBN
                  GestureDetector(
                    onTap: () => Clipboard.setData(
                      ClipboardData(text: book!.isbn),
                    ).then((value) =>
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                            t.general.misc.copied_clipboard,
                          ),
                        ))),
                    child: TextWithIconWidget(
                      icon: Icons.qr_code_2_rounded,
                      text: "ISBN: ${book!.isbn}",
                    ),
                  ),

                  // Show Publishers
                  if (book!.publishers.isNotEmpty)
                    TextWithIconWidget(
                      icon: Icons.storefront_rounded,
                      text: book!.publishers.reduce(
                        (value, element) => "$value, $element",
                      ),
                    ),

                  // Show authors
                  if (book!.authors.isNotEmpty)
                    TextWithIconWidget(
                      icon: Icons.people,
                      text: book!.authors.reduce(
                        (value, element) => "$value, $element",
                      ),
                    ),

                  // Show subjects
                  if (book!.subjects.isNotEmpty)
                    TextWithIconWidget(
                      icon: Icons.sell_rounded,
                      text: book!.subjects.reduce(
                        (value, element) => "$value, $element",
                      ),
                    ),

                  // Tag picker
                  SizedBox(
                    height: 80.0,
                    child: StatefulBuilder(
                      builder: (context, setState) {
                        return TagPickerWidget(
                          key: UniqueKey(),
                          showCreateTag: useThisBookInstead == null,
                          book: book!,
                          onSelect: (tag) => setState(() {
                            // Alter book
                            book = book!.copyWith(
                              tags: book!.tags.addOrRemoveTag(tag),
                            );
                            // Use the provider
                            if (useThisBookInstead == null) {
                              bookshelfProvider[book!.isbn] = book;
                            }
                          }),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}

/// Popup menu for context actions
class _PopupMenu extends StatelessWidget {
  const _PopupMenu(this.book);

  final Book book;

  @override
  Widget build(BuildContext context) => PopupMenuButton<int>(
        onSelected: (value) {
          switch (value) {
            case -1:
              showDialog(
                context: context,
                builder: (context) => const ContributeAlertDialog(),
              );
              break;
            case 0:
              showDialog(
                context: context,
                builder: (context) => BarcodePreviewDialog(book.isbn),
              );
              break;
            case 1:
              launchUrl(
                mode: LaunchMode.externalApplication,
                Uri.parse(book.url!),
              ).onError((error, stackTrace) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("URL: ${book.url}\nError:$error")),
                );

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
              Text(t.book.submenu.barcode_item),
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
              Text(t.book.submenu.visit_on_openlibrary),
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
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ]),
            ),
        ],
      );
}
