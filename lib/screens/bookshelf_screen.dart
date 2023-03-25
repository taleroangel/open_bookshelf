import 'package:flutter/material.dart';
import 'package:open_bookshelf/i18n/translations.g.dart';
import 'package:open_bookshelf/models/book.dart';
import 'package:open_bookshelf/providers/book_preview_provider.dart';
import 'package:open_bookshelf/providers/bookshelf_provider.dart';
import 'package:provider/provider.dart';

class BookshelfScreen extends StatelessWidget {
  final BookCollection filter;
  const BookshelfScreen(this.filter, {super.key});

  @override
  Widget build(BuildContext context) {
    // Obtain Providers
    final bookPreviewProvider = context.read<BookPreviewProvider>();
    final bookshelfProvider = context.watch<BookshelfProvider>();

    // Take only books where collection is same as filter
    final bookshelf = bookshelfProvider.books.values
        .toList()
        .where((value) => (value.collection == filter))
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(t.navigation.bookshelf)),
      body: bookshelf.isEmpty
          ? Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Icon(Icons.report,
                        size: 60.0,
                        color: Theme.of(context)
                            .colorScheme
                            .onBackground
                            .withAlpha(200)),
                  ),
                  Text(
                    t.bookshelf.no_books,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: bookshelf.length,
              itemBuilder: (context, idx) => ListTile(
                title: Text(bookshelf[idx].title),
                subtitle: Text(bookshelf[idx].isbn),
                onTap: () => bookPreviewProvider.navigateToBook(
                    context, bookshelf[idx].isbn),
              ),
            ),
    );
  }
}
