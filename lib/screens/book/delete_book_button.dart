import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:open_bookshelf/i18n/translations.g.dart';
import 'package:open_bookshelf/providers/bookshelf_provider.dart';

/// Button to delete current selected book in [IBookshelfProvider]
class DeleteBookButton extends StatelessWidget {
  const DeleteBookButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        // Show deletion confirmation prompt
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Text(t.book.delete.confirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  t.general.button.cancel,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  t.general.button.delete,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ).then((userConfirmed) {
          if (userConfirmed) {
            // Get the provider
            final provider = context.read<IBookshelfProvider>();
            // Erase the book
            provider[provider.selectedBook!.isbn] = null;
            // Show confirmation screen
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(t.book.delete.success),
            ));
            // Get out of the screen, to main menu
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else {
            // Show deletion failures
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(t.book.delete.failure),
            ));
          }
        });
      },
      icon: Icon(
        Icons.delete,
        color: Theme.of(context).colorScheme.error,
      ),
    );
  }
}
