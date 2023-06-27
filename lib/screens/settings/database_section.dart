import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:open_bookshelf/exceptions/database_exception.dart';
import 'package:open_bookshelf/i18n/translations.g.dart';
import 'package:open_bookshelf/providers/bookshelf_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

/// Export or Import database Settings
class DatabaseSection extends StatelessWidget {
  const DatabaseSection({super.key});

  void export(BuildContext context) async {
    // Scaffold messenger
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final contextTheme = Theme.of(context);

    // Try to export database
    try {
      // Export document to JSON
      final databaseJsonContent =
          context.read<IBookshelfProvider>().export<Map<String, Object?>>();

      // Store the file path
      String storePath;

      // Open a file picker and choose where to store the file on computer platforms
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        // Ask for the location of the file
        storePath = (await FilePicker.platform
            .saveFile(type: FileType.custom, allowedExtensions: [".json"]))!;
        // Normalize with heck if file contains extension and add it
        storePath = path.normalize(path.extension(storePath) == '.json'
            ? storePath
            : '$storePath.json');
      } else {
        // Get the basename
        final basename =
            '${DateFormat('dd_MM_yyyy').format(DateTime.now())}_openbookshelf';
        // Make the path
        storePath = path.join(
          (await (Platform.isAndroid
                  ? getExternalStorageDirectory()
                  : getDownloadsDirectory()))!
              .path,
          '$basename.json',
        );
      }

      // Show the filename
      GetIt.I.get<Logger>().v('Selected file was: $storePath');

      // Create the file and store contents
      final file = await File(storePath).create();
      await file.writeAsString(json.encode(databaseJsonContent));

      // Show creation
      GetIt.I.get<Logger>().i("Database storage file stored as: ${file.path}");

      // Show a Success snackbar
      scaffoldMessenger.showSnackBar(SnackBar(
        content: Text(
          t.settings.export_import.export.success(path: file.path),
        ),
      ));
    } catch (e) {
      // Show error message
      GetIt.I.get<Logger>().e(e);
      // Show a failure snackbar
      scaffoldMessenger.showSnackBar(SnackBar(
        content: Text(
          t.settings.export_import.export.failed,
          style: TextStyle(
            color: contextTheme.colorScheme.onError,
          ),
        ),
      ));
    }
  }

  void import(BuildContext context) {
    //File picker
    FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
    ).then((result) {
      if (result == null) {
        throw DatabaseException(
          message: "Failed to select file",
          source: FilePicker.platform.runtimeType.toString(),
        );
      }

      // Selected file
      final file = File(result.files.single.path!);

      // Read file contents in JSON format
      final Map<String, Object?> content = jsonDecode(file.readAsStringSync());

      // Database import json
      context.read<IBookshelfProvider>().importJson(content);

      // Show success
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        content: Text(
          t.settings.export_import.import.success,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ));
    }).catchError((e) {
      // Show error
      GetIt.I.get<Logger>().e(e);
      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Theme.of(context).colorScheme.error,
        content: Text(
          t.settings.export_import.import.failed,
          style: TextStyle(color: Theme.of(context).colorScheme.onError),
        ),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4.0,
      children: [
        ElevatedButton.icon(
          onPressed: () => export(context),
          icon: const Icon(Icons.upload_file_rounded),
          label: Text(t.settings.export_import.export.button),
        ),
        ElevatedButton.icon(
          onPressed: () => import(context),
          icon: const Icon(Icons.file_open_rounded),
          label: Text(t.settings.export_import.import.button),
        ),
      ],
    );
  }
}
