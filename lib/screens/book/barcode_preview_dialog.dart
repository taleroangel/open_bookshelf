import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:open_bookshelf/i18n/translations.g.dart';

/// Show a barcode preview of an ISBN in an [AlertDialog]
class BarcodePreviewDialog extends StatelessWidget {
  const BarcodePreviewDialog(this.isbn, {super.key});

  final String isbn;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(t.book.barcode.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 350, child: Text(t.book.barcode.description)),
          BarcodeWidget(
            data: isbn,
            backgroundColor: Colors.transparent,
            color: Theme.of(context).colorScheme.onBackground,
            barcode: Barcode.isbn(),
            padding: const EdgeInsets.all(32.0),
            errorBuilder: (context, error) => RichText(
              textAlign: TextAlign.center,
              text: TextSpan(children: [
                TextSpan(
                  text: t.general.misc.failed_barcode,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                TextSpan(
                  text: "\nISBN $isbn",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ]),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: Text(t.general.button.ok),
        ),
      ],
    );
  }
}
