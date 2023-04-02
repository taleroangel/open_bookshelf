import 'package:flutter/material.dart';
import 'package:open_bookshelf/models/book.dart';

const _titlePadding = 16.0;

class BookPickWidget extends StatefulWidget {
  const BookPickWidget({required this.book, required this.onTap, super.key});

  final Book book;
  final void Function(Book book) onTap;

  @override
  State<BookPickWidget> createState() => _BookPickWidgetState();
}

class _BookPickWidgetState extends State<BookPickWidget> {
  MemoryImage? showImage;

  @override
  Widget build(BuildContext context) {
    // Try and fetch the Image
    if (showImage == null) {
      widget.book.image.then(
        (value) => setState(() {
          showImage = MemoryImage(value);
        }),
      );
    }

    // Build the widget
    if (showImage != null) {
      return Card(
        elevation: 2,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: InkWell(
          onTap: () => widget.onTap.call(widget.book),
          child: Ink(
            decoration: BoxDecoration(
                image: DecorationImage(fit: BoxFit.cover, image: showImage!)),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Gradient
                Container(
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black, Colors.transparent],
                          stops: [0.0, 0.4])),
                ),

                // Show book title
                Positioned(
                  width: 120,
                  bottom: _titlePadding,
                  left: _titlePadding,
                  child: Text(
                    widget.book.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),

                Positioned(
                  right: _titlePadding,
                  bottom: _titlePadding,
                  child: Icon(
                    widget.book.collection.icon,
                    color: Colors.white70,
                  ),
                )
              ],
            ),
          ),
        ),
      );
    } else {
      return Card(
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
      );
    }
  }
}
