import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get_it/get_it.dart';
import 'package:open_bookshelf/i18n/translations.g.dart';
import 'package:open_bookshelf/providers/bookshelf_provider.dart';
import 'package:provider/provider.dart';

/// Alter local storage settings
class StorageSection extends StatefulWidget {
  const StorageSection({super.key});

  @override
  State<StorageSection> createState() => _StorageSectionState();
}

class _StorageSectionState extends State<StorageSection> {
  // Loading buttons state
  bool compactingDatabase = false;
  bool clearingCache = false;
  bool deletingDatabase = false;

  late final IBookshelfProvider bookshelfProvider;

  void compactDatabase() {
    // Set state to compaction
    setState(() => (compactingDatabase = true));

    // Start a compaction
    bookshelfProvider.compactDatabase().then((_) {
      // Show success
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(t.settings.local_storage.compact_database.success),
      ));
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(t.settings.local_storage.compact_database.failed),
      ));
    });

    // Set state to compactation
    setState(() => (compactingDatabase = false)); // Set state back to normal
  }

  void deleteDatabase() async {
    setState(() => (deletingDatabase = true)); // Set state to compaction

    // Show AlertDialog for user confirmation
    final response = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(t.settings.local_storage.delete_database.confirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t.general.button.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              t.general.button.delete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    // Wait for database deletion if user confirmed
    if (response == true) {
      bookshelfProvider.deleteDatabase();
    }

    setState(() => (deletingDatabase = false));
  }

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      bookshelfProvider = context.read<IBookshelfProvider>();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ammount of books stored
        Text(t.settings.local_storage
            .books_stored(books: bookshelfProvider.length)),
        // Size of the database
        FutureBuilder(
          future: bookshelfProvider.size,
          builder: (context, snapshot) =>
              Text(t.settings.local_storage.bookshelf_size(
            size: snapshot.data?.toStringAsFixed(2) ?? "...",
          )),
        ),

        const SizedBox(
          height: 8.0,
        ),

        // Buttons
        Column(
          children: [
            // Compact database button
            TextButton(
              onPressed: compactDatabase,
              child: Row(
                children: [
                  if (compactingDatabase)
                    const Padding(
                      padding: EdgeInsets.only(right: 16.0),
                      child: SizedBox.square(
                        dimension: 16.0,
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  Text(t.settings.local_storage.compact_database.button),
                ],
              ),
            ),

            // Button to delete the database
            TextButton(
              onPressed: deleteDatabase,
              child: Row(
                children: [
                  if (deletingDatabase)
                    const Padding(
                      padding: EdgeInsets.only(right: 16.0),
                      child: SizedBox.square(
                        dimension: 16.0,
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  Text(
                    t.settings.local_storage.delete_database.button,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
