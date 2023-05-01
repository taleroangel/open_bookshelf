import 'package:flutter/material.dart';
import 'package:open_bookshelf/providers/bookshelf_provider.dart';
import 'package:open_bookshelf/widgets/interactive_image.dart';

import 'package:provider/provider.dart';

import 'package:open_bookshelf/i18n/translations.g.dart';
import 'package:open_bookshelf/models/book.dart';
import 'package:open_bookshelf/widgets/exception_widget.dart';

/// Show the cover of a [Book]
/// Will use the 'selectedBook' from [IBookshelfProvider] if 'useThisBookInstead' is null
class BookCoverWidget extends StatelessWidget {
  const BookCoverWidget({this.useThisBookInstead, super.key});

  final Book? useThisBookInstead;

  @override
  Widget build(BuildContext context) {
    return Consumer<IBookshelfProvider>(
      builder: (context, provider, child) => FutureBuilder(
        future: (useThisBookInstead ?? provider.selectedBook)?.image,
        builder: (context, snapshot) {
          // If connectoin was successfull, then store image in internal cache
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return ExceptionWidget(exception: snapshot.error as Exception);
            }
            // No errors where found
            else {
              // Grap image from memory
              final image = Image.memory(
                snapshot.data!,
                fit: BoxFit.fitHeight,
                width: double.infinity,
              );

              return Hero(
                tag: "cover:zoom",
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => InteractiveImage(child: image),
                  )),
                  child: image,
                ),
              );
            }
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(t.covers.fetching),
              ),
            ],
          );
        },
      ),
    );
  }
}
