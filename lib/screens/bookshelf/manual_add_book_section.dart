import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:flutter/material.dart';
import 'package:open_bookshelf/i18n/translations.g.dart';
import 'package:open_bookshelf/models/book.dart';
import 'package:open_bookshelf/widgets/list_input_widget.dart';

/// Manually add a [Book] to the collection
class ManualAddBookSection extends StatefulWidget {
  const ManualAddBookSection({super.key});

  @override
  State<ManualAddBookSection> createState() => _ManualAddBookSectionState();
}

class _ManualAddBookSectionState extends State<ManualAddBookSection> {
  /// Book collection
  BookCollection collection = BookCollection.none;

  /// Book title
  final titleTextController = TextEditingController();

  /// Book subtitle
  final subtitleTextController = TextEditingController();

  /// Book ISBN
  final isbnTextController = TextEditingController();

  /// List of authors of the book
  List<String> authors = [];

  /// List of publishers of the book
  List<String> publishers = [];

  /// List of subjects for the book
  List<String> subjects = [];

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Book title
                Expanded(
                  child: TextField(
                    controller: titleTextController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: t.addbook.fields.title,
                    ),
                  ),
                ),
                // Collection
                DropdownMenu<BookCollection>(
                  onSelected: (value) => setState(() {
                    collection = value!;
                  }),
                  initialSelection: collection,
                  dropdownMenuEntries: BookCollection.values
                      .map(
                        (e) => DropdownMenuEntry(
                          value: e,
                          label: e.name.capitalize(),
                        ),
                      )
                      .toList(),
                ),
              ].separatedBy(
                const SizedBox(
                  width: 12.0,
                ),
              ),
            ),
            // Book subtitle
            TextField(
              controller: subtitleTextController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: t.addbook.fields.subtitle,
              ),
            ),
            // Book ISBN
            TextField(
              controller: isbnTextController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: t.addbook.fields.isbn,
              ),
            ),
            // Authors
            ListInputWidget<String>(
              items: authors,
              label: t.addbook.fields.authors,
              parseValue: (value) => value,
              onUpdate: (items) => setState(() {
                authors = items;
              }),
              onRemove: (item) => setState(() {
                authors.remove(item);
              }),
            ),
            // Publishers
            ListInputWidget<String>(
              items: publishers,
              label: t.addbook.fields.publishers,
              parseValue: (value) => value,
              onUpdate: (items) => setState(() {
                publishers = items;
              }),
              onRemove: (item) => setState(() {
                publishers.remove(item);
              }),
            ),
            // Subject
            ListInputWidget<String>(
              items: subjects,
              label: t.addbook.fields.subjects,
              parseValue: (value) => value,
              onUpdate: (items) => setState(() {
                subjects = items;
              }),
              onRemove: (item) => setState(() {
                subjects.remove(item);
              }),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: () {},
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  t.addbook.preview.add_book,
                ),
              ),
            )
          ].separatedBy(
            const SizedBox(
              height: 12.0,
            ),
          ),
        ),
      );
}
