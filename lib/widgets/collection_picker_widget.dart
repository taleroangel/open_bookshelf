import 'package:flutter/material.dart';
import 'package:open_bookshelf/models/book.dart';

class CollectionPickerWidget extends StatefulWidget {
  const CollectionPickerWidget({
    this.initialValue = BookCollection.none,
    required this.onSelect,
    super.key,
  });

  final BookCollection initialValue;
  final void Function(BookCollection value) onSelect;

  @override
  State<CollectionPickerWidget> createState() => _CollectionPickerWidgetState();
}

class _CollectionPickerWidgetState extends State<CollectionPickerWidget> {
  BookCollection? selected;

  @override
  Widget build(BuildContext context) {
    selected ??= widget.initialValue;

    return SegmentedButton<BookCollection>(
      segments: BookCollection.values
          .map((e) => ButtonSegment<BookCollection>(
                value: e,
                icon: Icon(e.icon),
                label: Text(
                  BookCollection.getLabel(e),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ))
          .toList(),
      selected: {selected!},
      onSelectionChanged: (collection) {
        setState(() {
          setState(() {
            selected = collection.first;
            widget.onSelect.call(collection.first);
          });
        });
      },
    );
  }
}
