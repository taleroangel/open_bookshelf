import 'package:flutter/material.dart';

import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';

import 'package:open_bookshelf/i18n/translations.g.dart';
import 'package:open_bookshelf/screens/bookshelf/isbn_query_search_section.dart';
import 'package:open_bookshelf/widgets/description_card_widget.dart';

class AddBookScreen extends StatelessWidget {
  const AddBookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final layout = [
      // ISBN insert
      DescriptionCardWidget(
        dividerHeight: 32.0,
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(32.0),
        crossAxisAlignment: CrossAxisAlignment.center,
        title: t.addbook.openlibrary.title,
        subtitle: t.addbook.openlibrary.subtitle,
        child: const ISBNQuerySearchSection(),
      ),

      // Manually insert
      DescriptionCardWidget(
        dividerHeight: 32.0,
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(32.0),
        crossAxisAlignment: CrossAxisAlignment.center,
        title: t.addbook.manual.title,
        subtitle: t.addbook.manual.subtitle,
        child: const Placeholder(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(t.addbook.title)),
      body: SlotLayout(
        config: <Breakpoint, SlotLayoutConfig>{
          Breakpoints.smallAndUp: SlotLayout.from(
            key: const Key('small_body'),
            builder: (_) => SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.max,
                children: layout,
              ),
            ),
          ),
          Breakpoints.large: SlotLayout.from(
            key: const Key('large_body'),
            builder: (_) => Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.max,
              children: layout.map((e) => Expanded(child: e)).toList(),
            ),
          ),
        },
      ),
    );
  }
}
