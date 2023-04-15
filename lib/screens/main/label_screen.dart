import 'package:flutter/material.dart';
import 'package:open_bookshelf/i18n/translations.g.dart';
import 'package:open_bookshelf/providers/bookshelf_provider.dart';
import 'package:provider/provider.dart';

class LabelsScreen extends StatelessWidget {
  const LabelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookshelfProvider = context.watch<BookshelfProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(t.navigation.labels)),
      body: bookshelfProvider.tags.isEmpty
          ? Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Icon(Icons.label_off,
                        size: 50.0,
                        color: Theme.of(context)
                            .colorScheme
                            .onBackground
                            .withAlpha(200)),
                  ),
                  Text(
                    t.labels.no_tags,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: bookshelfProvider.tags.length,
              itemBuilder: (context, index) {
                final tag = bookshelfProvider.tags.elementAt(index);
                return ListTile(
                  title: Text(tag.name),
                );
              },
            ),
    );
  }
}
