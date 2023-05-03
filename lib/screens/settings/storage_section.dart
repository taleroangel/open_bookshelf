import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:open_bookshelf/i18n/translations.g.dart';
import 'package:open_bookshelf/providers/bookshelf_provider.dart';
import 'package:open_bookshelf/services/storage/cache_storage_service.dart';
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
  bool deletingCache = false;
  bool deletingDatabase = false;

  void compactDatabase() {
    // Set state to compaction
    setState(() => (compactingDatabase = true));

    // Start a compaction
    context.read<IBookshelfProvider>().compactDatabase().then((_) {
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

  void deleteDatabase() {
    setState(() => (deletingDatabase = true)); // Set state to compaction
    // Show AlertDialog for user confirmation
    showDialog<bool>(
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
    ).then((response) {
      if (response == true) {
        context.read<IBookshelfProvider>().deleteDatabase().then((value) {
          setState(() => (deletingDatabase = false));
        });
      }
    });
  }

  void deleteCache() {
    // Change state to
    setState(() => (deletingDatabase = true)); // Set state to cache deletion
    // Prompt cache to delete the storage
    GetIt.I
        .get<CacheStorageService>()
        .delete(CacheStorageSource.images)
        .then((_) {
      // Show success
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(t.settings.local_storage.delete_cache.success),
      ));
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(t.settings.local_storage.delete_cache.failed),
      ));
    }).whenComplete(() => setState(
              () => (deletingDatabase = false),
            )); // Set state to cache deletion);
  }

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ammount of books stored
          Text(t.settings.local_storage.books_stored(
            books: context.read<IBookshelfProvider>().length,
          )),

          // Size of the cache
          FutureBuilder(
            future: GetIt.I
                .get<CacheStorageService>()
                .sizeOf(CacheStorageSource.images),
            builder: (context, snapshot) =>
                Text(t.settings.local_storage.cover_cache_size(
              size: snapshot.data?.toStringAsFixed(2) ?? "...",
            )),
          ),

          // Size of the database
          FutureBuilder(
            future: context.read<IBookshelfProvider>().size,
            builder: (context, snapshot) =>
                Text(t.settings.local_storage.bookshelf_size(
              size: snapshot.data?.toStringAsFixed(2) ?? "...",
            )),
          ),

          const SizedBox(
            height: 8.0,
          ),

          Column(
            // Buttons
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

              // Delete cover cache
              TextButton(
                onPressed: deleteCache,
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
                    Text(t.settings.local_storage.delete_cache.button),
                  ],
                ),
              ),

              // Button to delete the database
              TextButton(
                onPressed: deleteDatabase,
                child: Row(
                  children: [
                    if (deletingCache)
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
