import 'dart:io';

import 'package:flutter/material.dart';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import 'package:open_bookshelf/i18n/translations.g.dart';
import 'package:open_bookshelf/models/book.dart';
import 'package:open_bookshelf/providers/bookshelf_provider.dart';
import 'package:open_bookshelf/screens/book/book_screen.dart';
import 'package:open_bookshelf/screens/bookshelf/barcode_scanner_screen.dart';
import 'package:open_bookshelf/services/book_service.dart';

class ISBNQuerySearchSection extends StatefulWidget {
  const ISBNQuerySearchSection({super.key});

  @override
  State<ISBNQuerySearchSection> createState() => _ISBNQuerySearchSectionState();
}

class _ISBNQuerySearchSectionState extends State<ISBNQuerySearchSection> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  String isbn = '';
  bool isValidISBN = false;
  bool serchingBook = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Add the selected book to collection
  void onClickAddBook(Book value) {
    // Add book to collection
    context.read<IBookshelfProvider>()[value.isbn] = value;
    GetIt.I.get<Logger>().t("Added book with ISBN: ${value.isbn}");
    // Exit to main screen
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  /// Search book on OpenLibrary and show a [BookScreen] with the book to be
  /// added with a FAB to add them using [onClickAddBook]
  void searchBook() async {
    setState(() => (serchingBook = true));

    // Search if book is present in database
    if (context.read<IBookshelfProvider>()[isbn] != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.addbook.already_exists)));
      Navigator.of(context).pop();

      return;
    }

    // Book api service
    GetIt.I.get<IBookService>().fetchBook(isbn).then((Book? value) {
      if (value == null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Text(
              t.addbook.openlibrary.not_found,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            actions: [
              TextButton(
                onPressed: Navigator.of(context).pop,
                child: Text(t.general.button.ok),
              ),
            ],
          ),
        );
      } else {
        // Found book
        GetIt.I.get<Logger>().i("Found book: ${value.title}");
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => BookScreen(
            useThisBookInstead: value,
            // Show a FAB to add the Book to the library, this button is
            // extended when a large layout is detected
            floatingActionButton: SlotLayout(
              config: <Breakpoint, SlotLayoutConfig>{
                Breakpoints.smallAndUp: SlotLayout.from(
                  key: const Key('small_body'),
                  builder: (_) => FloatingActionButton(
                    child: const Icon(Icons.add_circle_rounded),
                    onPressed: () => onClickAddBook(value),
                  ),
                ),
                Breakpoints.large: SlotLayout.from(
                  key: const Key('large_body'),
                  builder: (_) => FloatingActionButton.extended(
                    label: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(t.addbook.preview.add_book),
                        ),
                        const Icon(Icons.add_circle_rounded),
                      ],
                    ),
                    onPressed: () => onClickAddBook(value),
                  ),
                ),
              },
            ),
          ),
        ));
      }
    }).onError((error, stackTrace) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    }).whenComplete(() => setState(() => (serchingBook = false)));
  }

  String? validatorISBN(String? value) {
    setState(() => isValidISBN = false);

    if (value == null || value.isEmpty) {
      return t.general.forms.error.empty_field;
    } else if (Barcode.isbn().isValid(value)) {
      setState(() => isValidISBN = true);

      return null;
    } else {
      return t.general.forms.error.invalid_format(format: 'ISBN');
    }
  }

  @override
  Widget build(BuildContext context) {
    /// Text controller logic
    _controller.addListener(() {
      setState(() {
        isbn = _controller.text;
      });
      _formKey.currentState?.validate();
    });

    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Show a barcode
          BarcodeWidget(
            padding: const EdgeInsets.all(32.0),
            data: isbn,
            barcode: isValidISBN ? Barcode.isbn() : Barcode.code128(),
            color: Theme.of(context).colorScheme.onSurface,
          ),
          const SizedBox(height: 16.0),
          // Form to input the value
          TextFormField(
            controller: _controller,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'ISBN',
            ),
            validator: validatorISBN,
          ),
          const SizedBox(height: 16.0),
          // Add book button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: isValidISBN
                // Search book if ISBN is valid
                ? () {
                    if (_formKey.currentState!.validate()) {
                      searchBook();
                    }
                  }
                // Disable button if not
                : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(t.addbook.openlibrary.submit),
                ),
                if (serchingBook)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: SizedBox.square(
                      dimension: 16.0,
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          if (Platform.isAndroid || Platform.isIOS)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.barcode_reader),
                label: Text(t.addbook.openlibrary.scan),
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                    builder: (_) => const BarcodeScannerScreen(),
                  ))
                      .then((value) {
                    _controller.text = value;
                    _formKey.currentState?.validate();
                  });
                },
              ),
            ),
        ],
      ),
    );
  }
}
