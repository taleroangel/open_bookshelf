import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:open_bookshelf/i18n/translations.g.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:open_bookshelf/models/book.dart';
import 'package:open_bookshelf/screens/book_screen.dart';
import 'package:open_bookshelf/services/book_api_service.dart';
import 'package:open_bookshelf/services/book_database_service.dart';
import 'package:open_bookshelf/widgets/description_card_widget.dart';

class AddBookScreen extends StatelessWidget {
  const AddBookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final layout = [
      // ISBN insert
      DescriptionCard(
        dividerHeight: 32.0,
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(32.0),
        crossAxisAlignment: CrossAxisAlignment.center,
        title: t.addbook.openlibrary.title,
        subtitle: t.addbook.openlibrary.subtitle,
        child: const _ISBNQuerySearch(),
      ),

      // Manually insert
      DescriptionCard(
        dividerHeight: 32.0,
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(32.0),
        crossAxisAlignment: CrossAxisAlignment.center,
        title: t.addbook.manual.title,
        subtitle: t.addbook.manual.subtitle,
        child: const Placeholder(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(t.addbook.title)),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SlotLayout(
          config: <Breakpoint, SlotLayoutConfig>{
            Breakpoints.smallAndUp: SlotLayout.from(
              key: const Key('small_body'),
              builder: (_) => SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.max,
                  children: layout,
                ),
              ),
            ),
            Breakpoints.large: SlotLayout.from(
              key: const Key('large_body'),
              builder: (_) => Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.max,
                children: layout.map((e) => Expanded(child: e)).toList(),
              ),
            )
          },
        ),
      ),
    );
  }
}

class _ISBNQuerySearch extends StatefulWidget {
  const _ISBNQuerySearch();

  @override
  State<_ISBNQuerySearch> createState() => _ISBNQuerySearchState();
}

class _ISBNQuerySearchState extends State<_ISBNQuerySearch> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;
  final bookDatabase = GetIt.I.get<BookDatabaseService>();

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

  void searchBook() {
    // Search if book is present in database
    if (bookDatabase.database.get(isbn) != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.addbook.already_exists)));
      Navigator.of(context).pop();
      return;
    }

    // Book api service
    GetIt.I
        .get<BookApiService>()
        .fetchBookFromOpenLibrary(isbn)
        .then((Book? value) {
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
                        child: Text(
                          t.navigation.ok_button,
                        ))
                  ],
                ));
      } else {
        // Found book
        GetIt.I.get<Logger>().i("Found book: ${value.title}");
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => BookScreen(
            useThisBookInstead: value,
            floatingActionButton: FloatingActionButton.extended(
              label: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(t.addbook.preview.add_book),
                  ),
                  const Icon(Icons.add_circle_rounded)
                ],
              ),
              onPressed: () async {
                final navigator = Navigator.of(context);
                // Add book to collection
                await bookDatabase.database.put(value.isbn, value);
                GetIt.I.get<Logger>().v("Added book with ISBN: ${value.isbn}");
                // Exit to main screen
                navigator.popUntil((route) => route.isFirst);
              },
            ),
          ),
        ));
      }
    }).onError((error, stackTrace) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          BarcodeWidget(
            padding: const EdgeInsets.all(32.0),
            data: isbn,
            barcode: isValidISBN ? Barcode.isbn() : Barcode.code128(),
            color: Theme.of(context).colorScheme.onSurface,
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: _controller,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'ISBN',
            ),
            onChanged: (value) {
              setState(() {
                isValidISBN = false;
                isbn = value;
              });
              _formKey.currentState?.validate();
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return t.forms.error_empty_field;
              } else if (Barcode.isbn().isValid(value)) {
                setState(() => isValidISBN = true);
                return null;
              } else {
                return t.forms.error_invalid_format(format: 'ISBN');
              }
            },
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary),
              onPressed: !isValidISBN
                  ? null // Disable is not a valid ISBN
                  : // Enable on ISBN
                  () {
                      setState(() => (serchingBook = true));
                      if (_formKey.currentState!.validate()) {
                        searchBook();
                      }
                      setState(() => (serchingBook = false));
                    },
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
                          )),
                    )
                ],
              ))
        ],
      ),
    );
  }
}
