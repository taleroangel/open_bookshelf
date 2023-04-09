import 'package:flutter/material.dart';
import 'package:open_bookshelf/models/book.dart';

const _titlePadding = 16.0;

//TODO: Check and improve
class BookPickWidget extends StatelessWidget {
  const BookPickWidget({required this.book, required this.onTap, super.key});

  final Book book;
  final void Function(Book book) onTap;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: book.image,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Card(
            elevation: 2,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: InkWell(
              onTap: () => onTap.call(book),
              child: Ink(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.cover, image: MemoryImage(snapshot.data!))),
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
                        book.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),

                    Positioned(
                      right: _titlePadding,
                      bottom: _titlePadding,
                      child: Icon(
                        book.collection.icon,
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
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ]),
          );
        }
      },
    );
  }
}
