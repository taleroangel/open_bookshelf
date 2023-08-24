import 'package:flutter/material.dart';

import 'package:open_bookshelf/i18n/translations.g.dart';
import 'package:open_bookshelf/screens/settings/about_section.dart';
import 'package:open_bookshelf/screens/settings/database_section.dart';
import 'package:open_bookshelf/screens/settings/storage_section.dart';
import 'package:open_bookshelf/widgets/description_card_widget.dart';

/// Show app settings
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t.navigation.settings)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Export and Import the database
            DescriptionCardWidget(
              title: t.settings.export_import.title,
              subtitle: t.settings.export_import.subtitle,
              child: const DatabaseSection(),
            ),
            DescriptionCardWidget(
              title: t.settings.local_storage.title,
              subtitle: t.settings.local_storage.subtitle,
              child: const StorageSection(),
            ),
            DescriptionCardWidget(
              title: t.settings.about.title,
              subtitle: t.settings.about.subtitle,
              child: const AboutSection(),
            ),
          ],
        ),
      ),
    );
  }
}
