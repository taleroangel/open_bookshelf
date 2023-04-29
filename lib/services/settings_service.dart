import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:open_bookshelf/exceptions/database_exception.dart';
import 'package:open_bookshelf/interfaces/database_controller.dart';
import 'package:open_bookshelf/interfaces/json_manipulator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingsService {
  SettingsService({required this.databaseController});

  final IDatabaseController databaseController;

  Future<File> export() async {
    // Get the platform download directory
    //TODO: Doesn't work for Android
    if (Platform.isAndroid) {
      await Permission.storage.request();
    }

    final platformDirectory = await getDownloadsDirectory();

    if (platformDirectory == null) {
      throw UnsupportedError("Unsupported platform");
    }

    // Get the database as a JSON
    final databaseJson = await databaseController.export<JsonDocument>();

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

  Future<void> import() async {
    // File picker
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
    );

    // Any file selected
    if (result == null) {
      throw const DatabaseException(message: "Failed to select file");
    }

    // Selected file
    final file = File(result.files.single.path!);

    // Read file contents in JSON format
    final content = jsonDecode(await file.readAsString()) as JsonDocument;

    // Database import
    databaseController.import(content);
  }

  Future<void> databaseCompactation() async {
    await databaseController.database.compact();
  }
}
