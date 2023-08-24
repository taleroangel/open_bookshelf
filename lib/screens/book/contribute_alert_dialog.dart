import 'package:flutter/material.dart';
import 'package:open_bookshelf/constants/open_library_endpoints.dart';
import 'package:open_bookshelf/i18n/translations.g.dart';
import 'package:url_launcher/url_launcher.dart';

/// Show a 'contribute on OpenBookshelf' [AlertDialog]
class ContributeAlertDialog extends StatelessWidget {
  const ContributeAlertDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(t.book.contribute.title),
      content: SizedBox(
        width: 350,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              t.book.contribute.summary,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(
              height: 8.0,
            ),
            Text(t.book.contribute.what_is_openlibrary),
            const SizedBox(
              height: 8.0,
            ),
            Text(t.book.contribute.why_contribute),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: Text(t.book.contribute.skip),
        ),
        TextButton.icon(
          onPressed: () {
            launchUrl(
              mode: LaunchMode.externalApplication,
              Uri.parse(OpenLibraryEndpoints.contribute),
            ).onError((error, stackTrace) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  "URL: ${OpenLibraryEndpoints.contribute}\nError:$error",
                ),
              ));

              return true;
            });
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.favorite),
          label: Text(t.book.contribute.contribute),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
