import 'dart:convert';
import 'dart:io';

import 'package:open_bookshelf/interfaces/database_controller.dart';
import 'package:open_bookshelf/interfaces/json_manipulator.dart';
import 'package:path_provider/path_provider.dart';

class SettingsService {
  SettingsService({required this.databaseController});

  final IDatabaseController databaseController;

  Future<File> export() async {
    // Get the platform download directory
    final platformDirectory = await (Platform.isAndroid
        ? getExternalStorageDirectory()
        : getDownloadsDirectory());

    if (platformDirectory == null) {
      throw UnsupportedError("Unsupported platform");
    }

    // Get the database as a JSON
    final databaseJson = databaseController.export<JsonDocument>();

    // Parse filename
    final timestamp = DateTime.now().toUtc().toString().split(' ')[0];
    final file =
        File('${platformDirectory.path}/openbookshelf_backup_$timestamp.json');

    // Create and write file
    await file.create();
    await file.writeAsString(jsonEncode(databaseJson));

    // Return the filename
    return file;
  }

  Future<void> databaseCompactation() async {
    await databaseController.database.compact();
  }
}
