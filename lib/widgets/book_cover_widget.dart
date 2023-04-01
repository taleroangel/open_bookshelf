import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:open_bookshelf/providers/bookshelf_provider.dart';
import 'package:open_bookshelf/screens/cover_screen.dart';
import 'package:open_bookshelf/widgets/exception_widget.dart';
import 'package:provider/provider.dart';

class BookCoverWidget extends StatelessWidget {
  const BookCoverWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookshelfProvider>();
    return FutureBuilder(
        future: provider.selectedBook?.image,
        builder: (context, snapshot) {
          // If connectoin was successfull, then store image in internal cache
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return ExceptionWidget(exception: snapshot.error as Exception);
            }

            // No errors where found
            else {
              // Grap image from memory
              final image = Image.memory(snapshot.data!);
              // Show it inside an expanded
              return Hero(
                tag: "cover:zoom",
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => CoverScreen(child: image))),
                  child: image,
                ),
              );
            }
          }

          // If no cache found then show a progress indicator
          else {
            return const CircularProgressIndicator();
          }
        });
  }
}
