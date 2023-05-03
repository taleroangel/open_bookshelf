import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:open_bookshelf/i18n/translations.g.dart';
import 'package:open_bookshelf/providers/bookshelf_provider.dart';
import 'package:open_bookshelf/screens/tags/tag_expandable.dart';

class TagsScreen extends StatelessWidget {
  const TagsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get tags from provider
    final tags = context.watch<IBookshelfProvider>().tags.toSortedList();

    return Scaffold(
      appBar: AppBar(title: Text(t.navigation.labels)),
      body: tags.isEmpty
          ? Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Icon(
                      Icons.label_off,
                      size: 50.0,
                      color: Theme.of(context)
                          .colorScheme
                          .onBackground
                          .withAlpha(200),
                    ),
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
              itemCount: tags.length,
              itemBuilder: (context, index) => TagExpandable(
                key: ObjectKey(tags.elementAt(index)),
                initExpanded: index == 0,
                tag: tags.elementAt(index),
              ),
            ),
    );
  }
}
