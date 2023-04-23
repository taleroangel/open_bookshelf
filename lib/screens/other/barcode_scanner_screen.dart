import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:open_bookshelf/i18n/translations.g.dart';
import 'package:open_bookshelf/widgets/exception_widget.dart';

class BarcodeScannerScreen extends StatelessWidget {
  const BarcodeScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var popAvailable = true;

    return Scaffold(
      appBar: AppBar(title: Text(t.addbook.openlibrary.scan)),
      body: MobileScanner(
        errorBuilder: (context, error, _) => ExceptionWidget(exception: error),
        onDetect: (capture) {
          if (popAvailable) {
            // Return the latest barcode
            Navigator.of(context).pop(capture.barcodes.first.displayValue!);
            popAvailable = false;
          }
        },
      ),
    );
  }
}
