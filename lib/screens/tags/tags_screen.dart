import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:open_bookshelf/i18n/translations.g.dart';
import 'package:open_bookshelf/providers/bookshelf_provider.dart';
import 'package:open_bookshelf/widgets/tag_item_widget.dart';

class TagsScreen extends StatelessWidget {
  const TagsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get bookshelf provider
    final provider = context.watch<IBookshelfProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(t.navigation.labels)),
      body: provider.tags.isEmpty
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
              itemCount: provider.tags.length,
              itemBuilder: (context, index) => TagItemWidget(
                key: ObjectKey(provider.tags.elementAt(index)),
                initExpanded: index == 0,
                tag: provider.tags.elementAt(index),
              ),
            ),
    );
  }
}
