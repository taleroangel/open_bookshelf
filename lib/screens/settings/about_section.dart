import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:open_bookshelf/i18n/translations.g.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(t.settings.about.credits),
        Text(t.settings.about.license),
        const Divider(),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: t.settings.about.flutter.split("{}").first,
              ),
              const WidgetSpan(
                child: FlutterLogo(
                  size: 16.0,
                ),
              ),
              TextSpan(
                text: t.settings.about.flutter.split("{}").last,
              ),
            ],
          ),
        ),
        Text(t.settings.about.openlibrary),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.people_alt_rounded),
            label: Text(t.settings.about.github),
            onPressed: () => launchUrl(
              Uri.parse(
                "https://github.com/taleroangel/open_bookshelf",
              ),
              mode: LaunchMode.externalApplication,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.privacy_tip_rounded),
            label: Text(t.settings.about.dialog),
            onPressed: () => showAboutDialog(
              context: context,
              applicationName: t.app.name,
              applicationLegalese: t.app.legalese,
            ),
          ),
        ),
      ],
    );
  }
}
