import 'dart:convert';
import 'dart:io';

import 'package:open_bookshelf/services/book_database_service.dart';
import 'package:open_bookshelf/widgets/description_card_widget.dart';
import 'package:open_bookshelf/i18n/translations.g.dart';
import 'package:open_bookshelf/services/cache_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';

/// Show app settings
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(t.navigation.settings)),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Export and Import the database
                DescriptionCard(
                  title: t.settings.export_import.title,
                  subtitle: t.settings.export_import.subtitle,
                  child: const _ExportImport(),
                ),
                DescriptionCard(
                  title: t.settings.local_storage.title,
                  subtitle: t.settings.local_storage.subtitle,
                  child: const _LocalStorage(),
                ),
              ],
            ),
          ),
        ));
  }
}

/// Export or Import database Settings
class _ExportImport extends StatelessWidget {
  const _ExportImport();

  void export(BuildContext context) async {
    final scaffold = ScaffoldMessenger.of(context);

    // Get database json
    final databaseJson = GetIt.I.get<BookDatabaseService>().getDatabaseJson();
    final platformDirectory = await (Platform.isAndroid
        ? getExternalStorageDirectory()
        : getDownloadsDirectory());

    if (platformDirectory == null) {
      scaffold.showSnackBar(
          SnackBar(content: Text(t.settings.export_import.export.failed)));
      return;
    }

    // Create a timestamp
    final timestamp = DateTime.now().toUtc().toString().split(' ')[0];
    final file =
        File('${platformDirectory.path}/openbookshelf_backup_$timestamp.json');

    // Create and write files
    await file.create();
    await file.writeAsString(jsonEncode(databaseJson));

    // Show success
    scaffold.showSnackBar(SnackBar(
        content:
            Text(t.settings.export_import.export.success(path: file.path))));
  }

  void import(BuildContext context) {
    // TODO: Implement
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Theme.of(context).colorScheme.error,
        content: Text(
          "Operation is not yet supported",
          style: TextStyle(color: Theme.of(context).colorScheme.onError),
        )));
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4.0,
      children: [
        ElevatedButton.icon(
            onPressed: () => export(context),
            icon: const Icon(Icons.upload_file_rounded),
            label: Text(t.settings.export_import.export.button)),
        ElevatedButton.icon(
            onPressed: () => import(context),
            icon: const Icon(Icons.file_open_rounded),
            label: Text(t.settings.export_import.import.button))
      ],
    );
  }
}

/// Alter local storage settings
class _LocalStorage extends StatefulWidget {
  const _LocalStorage();

  @override
  State<_LocalStorage> createState() => _LocalStorageState();
}

class _LocalStorageState extends State<_LocalStorage> {
  bool compactingDatabase = false;
  bool clearingCache = false;
  bool deletingDatabase = false;

  Future<void> clearCache() async {
    setState(() => (clearingCache = true)); // Set state to compaction

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Show an AlertDialog for user confirmation
    final userConfirmation = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(t.settings.local_storage.delete_cache.confirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(t.general.button.cancel)),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                t.general.button.delete,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              )),
        ],
      ),
    );

    // If user confirmed deletion, delete Cache
    if (userConfirmation == true) {
      // Try to delete the cache
      bool cacheWasDeleted = await GetIt.I
          .get<CacheStorageService>()
          .deleteCache(StorageSource.imageCache);
      // Show snackbar
      scaffoldMessenger.showSnackBar(SnackBar(
          content: Text(cacheWasDeleted
              ? t.settings.local_storage.delete_cache.success
              : t.settings.local_storage.delete_cache.failed)));
    }

    setState(() => (clearingCache = false)); // Set state to compaction
  }

  void compactDatabase() async {
    // Set state to compaction
    setState(() => (compactingDatabase = true));

    // Start a compaction
    try {
      // Store scaffold messenger
      final contextScaffold = ScaffoldMessenger.of(context);
      // Compact and wait for an extra second for animation purposes
      await GetIt.I
          .get<BookDatabaseService>()
          .database
          .compact()
          .then((_) => Future.delayed(const Duration(seconds: 1)));
      // Show success
      contextScaffold.showSnackBar(SnackBar(
          content: Text(t.settings.local_storage.compact_database.success)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(t.settings.local_storage.compact_database.failed)));
    } finally {
      setState(() => (compactingDatabase = false)); // Set state back to normal
    }
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
              child: Text(t.general.button.cancel)),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                t.general.button.delete,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              )),
        ],
      ),
    );

    // Wait for database deletion if user confirmed
    if (response == true) {
      await GetIt.I.get<BookDatabaseService>().deleteDatabase();
    }
    setState(() => (deletingDatabase = false));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ammount of books stored
        Text(t.settings.local_storage.books_stored(
            books: GetIt.I.get<BookDatabaseService>().database.length)),
        // Size of the database
        FutureBuilder(
            future: GetIt.I.get<BookDatabaseService>().getDatabaseSize(),
            builder: (context, snapshot) => Text(t.settings.local_storage
                .bookshelf_size(
                    size: snapshot.data?.toStringAsFixed(2) ?? "..."))),
        // Size of the cache
        FutureBuilder(
            future: GetIt.I
                .get<CacheStorageService>()
                .getCacheSize(StorageSource.imageCache),
            builder: (context, snapshot) => Text(t.settings.local_storage
                .cover_cache_size(
                    size: snapshot.data?.toStringAsFixed(2) ?? "..."))),

        const SizedBox(
          height: 8.0,
        ),

        // Buttons
        Column(
          children: [
            // Delete cache button
            TextButton(
                onPressed: clearCache,
                child: Row(
                  children: [
                    if (clearingCache)
                      const Padding(
                        padding: EdgeInsets.only(right: 16.0),
                        child: SizedBox.square(
                            dimension: 16.0,
                            child: CircularProgressIndicator()),
                      ),
                    Text(t.settings.local_storage.delete_cache.button),
                  ],
                )),

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
                            child: CircularProgressIndicator()),
                      ),
                    Text(t.settings.local_storage.compact_database.button),
                  ],
                )),

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
                            child: CircularProgressIndicator()),
                      ),
                    Text(
                      t.settings.local_storage.delete_database.button,
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                )),
          ],
        )
      ],
    );
  }
}
