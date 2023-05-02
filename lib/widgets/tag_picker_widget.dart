import 'package:flutter/material.dart';

import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

import 'package:open_bookshelf/i18n/translations.g.dart';
import 'package:open_bookshelf/models/book.dart';
import 'package:open_bookshelf/models/tag.dart';
import 'package:open_bookshelf/providers/bookshelf_provider.dart';

/// Show all registered [Tag] (and an 'add tag' button if 'showCreateTag' is True)
class TagPickerWidget extends StatelessWidget {
  const TagPickerWidget({
    required this.book,
    required this.onSelect,
    this.showCreateTag = true,
    super.key,
  });

  final void Function(Tag selected) onSelect;
  final Book book;
  final bool showCreateTag;

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    final bookshelfProvider = context.watch<IBookshelfProvider>();

    // List of tags
    final widgetTags = [
      // Show create tag first
      if (showCreateTag)
        ActionChip(
          label: Text(t.labels.add),
          avatar: const Icon(Icons.add),
          onPressed: () => showDialog(
            context: context,
            builder: (context) => const _AddNewTagDialog(),
          ).then((value) {
            // Response
            if (value is Map<String, dynamic> &&
                (value['label'] as String).isNotEmpty) {
              // Create the tag
              final tag = Tag(name: value['label'], color: value['color']);

              // Check that it is unique
              if (!bookshelfProvider.tags.contains(tag)) {
                onSelect(tag);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t.labels.already_exists)),
                );
              }
            }
          }),
        ),
      // Show other tags sorted by hashCode
      ...(context.read<IBookshelfProvider>().tags.toList()
            ..sort(
              (a, b) => a.hashCode - b.hashCode,
            ))
          // Map every tag to an ActionChip
          .map((e) => ActionChip(
                key: ObjectKey(e),
                elevation: book.tags.contains(e) ? 10 : 0,
                onPressed: () => onSelect(e),
                label: Text(e.name),
                avatar: Container(
                  decoration:
                      BoxDecoration(shape: BoxShape.circle, color: e.color),
                ),
              ))
          .toList(),
    ];

    return Scrollbar(
      controller: scrollController,
      child: SingleChildScrollView(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          scrollDirection: Axis.horizontal,
          itemCount: widgetTags.length,
          separatorBuilder: (context, index) => const SizedBox(width: 5.0),
          itemBuilder: (context, index) => widgetTags[index],
          shrinkWrap: true,
        ),
      ),
    );
  }
}

class _AddNewTagDialog extends StatelessWidget {
  const _AddNewTagDialog();

  @override
  Widget build(BuildContext context) {
    // Variables
    var label = "";
    var color = Theme.of(context).colorScheme.primary;

    return AlertDialog(
      title: Text(t.labels.add),
      content: StatefulBuilder(
        builder: (context, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: (value) => (label = value),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: t.labels.label,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 30,
                    width: 40,
                    decoration:
                        BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox.square(dimension: 8.0),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(t.labels.select_color),
                          actions: [
                            ElevatedButton(
                              onPressed: Navigator.of(context).pop,
                              child: Text(t.general.button.ok),
                            ),
                          ],
                          content: SingleChildScrollView(
                            child: ColorPicker(
                              pickerColor: color,
                              onColorChanged: (value) {
                                setState(() {
                                  color = value;
                                });
                              },
                            ),
                          ),
                        ),
                      );
                    },
                    child: Text(t.labels.select_color),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: Text(t.general.button.cancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context)
              .pop(<String, dynamic>{"label": label, "color": color}),
          child: Text(t.general.button.ok),
        ),
      ],
    );
  }
}
