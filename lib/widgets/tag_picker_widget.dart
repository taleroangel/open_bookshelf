import 'package:flutter/material.dart';
import 'package:open_bookshelf/i18n/translations.g.dart';
import 'package:open_bookshelf/models/tag.dart';
import 'package:open_bookshelf/models/book.dart';
import 'package:open_bookshelf/providers/bookshelf_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class TagPickerWidget extends StatelessWidget {
  const TagPickerWidget(
      {required this.onSelect, required this.book, super.key});

  final void Function(Tag selected) onSelect;
  final Book book;

  @override
  Widget build(BuildContext context) {
    final bookshelfProvider = context.watch<BookshelfProvider>();
    final tags = bookshelfProvider.tags.map((e) {
      return ActionChip(
        elevation: book.tags.contains(e) ? 10 : 0,
        onPressed: () => onSelect(e),
        label: Text(e.name),
        avatar: Container(
            decoration: BoxDecoration(shape: BoxShape.circle, color: e.color)),
      );
    }).toList()
      ..add(ActionChip(
        label: Text(t.labels.add),
        avatar: const Icon(Icons.add),
        onPressed: () => showDialog(
          context: context,
          builder: (context) => const _CreateTag(),
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
                  SnackBar(content: Text(t.labels.already_exists)));
            }
          }
        }),
      ));

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      scrollDirection: Axis.horizontal,
      itemCount: tags.length,
      separatorBuilder: (context, index) => const SizedBox(width: 5.0),
      itemBuilder: (context, index) => tags[index],
      shrinkWrap: true,
    );
  }
}

class _CreateTag extends StatelessWidget {
  const _CreateTag();

  @override
  Widget build(BuildContext context) {
    // Variables
    var label = "";
    var color = Theme.of(context).colorScheme.primary;

    return AlertDialog(
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
                                  child: Text(t.general.button.ok))
                            ],
                            content: SingleChildScrollView(
                                child: ColorPicker(
                              pickerColor: color,
                              onColorChanged: (value) {
                                setState(() {
                                  color = value;
                                });
                              },
                            )),
                          ),
                        );
                      },
                      child: Text(t.labels.select_color)),
                ],
              ),
            )
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: Navigator.of(context).pop,
            child: Text(t.general.button.cancel)),
        ElevatedButton(
            onPressed: () => Navigator.of(context)
                .pop(<String, dynamic>{"label": label, "color": color}),
            child: Text(t.general.button.ok))
      ],
    );
  }
}
