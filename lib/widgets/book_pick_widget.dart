import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_bookshelf/models/book.dart';
import 'exception_widget.dart';

class BookPickWidget extends StatefulWidget {
  const BookPickWidget({required this.book, required this.onTap, super.key});

  final Book book;
  final void Function(Book book) onTap;

  @override
  State<BookPickWidget> createState() => _BookPickWidgetState();
}

class _BookPickWidgetState extends State<BookPickWidget> {
  Widget? showImage;

  @override
  Widget build(BuildContext context) {
    // Try and fetch the Image
    if (showImage == null) {
      widget.book.image.then(
        (value) => setState(() {
          showImage = Image.memory(
            value,
            fit: BoxFit.fill,
          );
        }),
      );
    }

    return GestureDetector(
      onTap: () => widget.onTap.call(widget.book),
      child: showImage != null
          ? Card(
              semanticContainer: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  showImage!,
                  Container(
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Colors.black, Colors.transparent])),
                  ),
                  Positioned(
                    width: 150,
                    bottom: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        widget.book.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            )
          : Card(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Spacer(),
                    const CircularProgressIndicator(),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        widget.book.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  ]),
            ),
    );
  }
}
