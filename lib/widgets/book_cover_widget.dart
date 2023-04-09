import 'package:flutter/material.dart';
import 'package:open_bookshelf/i18n/translations.g.dart';
import 'package:open_bookshelf/models/book.dart';
import 'package:open_bookshelf/providers/bookshelf_provider.dart';
import 'package:open_bookshelf/screens/cover_screen.dart';
import 'package:open_bookshelf/widgets/exception_widget.dart';
import 'package:provider/provider.dart';

class BookCoverWidget extends StatefulWidget {
  const BookCoverWidget({this.selectedBook, super.key});

  final Book? selectedBook;

  @override
  State<BookCoverWidget> createState() => _BookCoverWidgetState();
}

class _BookCoverWidgetState extends State<BookCoverWidget> {
  // Current Widget
  Widget showCurrentWidget = Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const CircularProgressIndicator(),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(t.covers.fetching),
      )
    ],
  );

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookshelfProvider>();
    return FutureBuilder(
        future: (widget.selectedBook ?? provider.selectedBook)?.image,
        builder: (context, snapshot) {
          // If connectoin was successfull, then store image in internal cache
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              showCurrentWidget =
                  ExceptionWidget(exception: snapshot.error as Exception);
            }
            // No errors where found
            else {
              // Grap image from memory
              final image = Image.memory(snapshot.data!);
              // Show it inside an expanded
              showCurrentWidget = Hero(
                tag: "cover:zoom",
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => CoverScreen(child: image))),
                  child: image,
                ),
              );
            }
          }
          return AnimatedSwitcher(
            switchInCurve: Curves.decelerate,
            duration: const Duration(milliseconds: 500),
            child: showCurrentWidget,
          );
        });
  }
}
