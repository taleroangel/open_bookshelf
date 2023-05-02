import 'package:flutter/material.dart';
import 'package:open_bookshelf/models/tag.dart';
import 'package:expandable/expandable.dart';
import 'package:open_bookshelf/providers/bookshelf_provider.dart';
import 'package:open_bookshelf/widgets/book_pick_card_widget.dart';
import 'package:provider/provider.dart';

const _gridSpacing = 1.0;

/// Show an [Expandable] of a tag with the corresponding books classified
class TagExpandable extends StatelessWidget {
  const TagExpandable({
    required this.tag,
    this.initExpanded = false,
    super.key,
  });

  final Tag tag;
  final bool initExpanded;

  @override
  Widget build(BuildContext context) {
    final bookshelfProvider = context.watch<IBookshelfProvider>();

    // List of books with specified tag
    final booksWithTag = bookshelfProvider.books
        .filterByTag(tag)
        .map((e) => BookPickCardWidget(
              book: e,
              onTap: (book) {
                // Set selected book as current book
                bookshelfProvider.selectedBook = book;
                // Dispatch book selection notification
                context.dispatchNotification(OnBookSelectionNotification());
              },
            ))
        .toList();

    final header = ListTile(
      leading: Container(
        width: 35,
        decoration: BoxDecoration(color: tag.color, shape: BoxShape.circle),
      ),
      title: Text(tag.name),
      trailing: ExpandableButton(
        child: const Icon(Icons.more_horiz_rounded),
      ),
    );

    return ExpandableNotifier(
      initialExpanded: initExpanded,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Expandable(
            collapsed: header,
            expanded: Column(
              children: [
                header,
                const Divider(),
                LayoutBuilder(
                  builder: (_, constraints) => GridView.count(
                    shrinkWrap: true,
                    crossAxisCount:
                        constraints.maxWidth ~/ BookPickCardWidget.boxSize,
                    padding: const EdgeInsets.all(2 * _gridSpacing),
                    childAspectRatio: BookPickCardWidget.boxAspectRatio,
                    mainAxisSpacing: 2 * _gridSpacing,
                    crossAxisSpacing: _gridSpacing,
                    children: booksWithTag,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
