import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:open_bookshelf/exceptions/database_exception.dart';

import 'package:open_bookshelf/i18n/translations.g.dart';
import 'package:open_bookshelf/providers/bookshelf_provider.dart';
import 'package:provider/provider.dart';

import 'package:file_picker/file_picker.dart';

import 'dart:io';

/// Export or Import database Settings
class DatabaseSection extends StatelessWidget {
  const DatabaseSection({super.key});

  void export(BuildContext context) {
    try {
      // Export document to JSON
      final exportedJson =
          context.read<IBookshelfProvider>().export<Map<String, Object?>>();

      // TODO: Generate file and share it
    } catch (e) {
      // Show error message
      GetIt.I.get<Logger>().e(e);
      // Show a failure snackbar
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          t.settings.export_import.export.failed,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onError,
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
