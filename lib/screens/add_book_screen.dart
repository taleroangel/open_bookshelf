import 'package:flutter/material.dart';
import 'package:open_bookshelf/i18n/translations.g.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:open_bookshelf/widgets/description_card_widget.dart';

class AddBookScreen extends StatelessWidget {
  const AddBookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final layout = [
      // ISBN insert
      DescriptionCard(
        dividerHeight: 32.0,
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(32.0),
        crossAxisAlignment: CrossAxisAlignment.center,
        title: t.addbook.openlibrary.title,
        subtitle: t.addbook.openlibrary.subtitle,
        child: const _ISBNQuerySearch(),
      ),

      // Manually insert
      DescriptionCard(
        dividerHeight: 32.0,
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(32.0),
        crossAxisAlignment: CrossAxisAlignment.center,
        title: t.addbook.manual.title,
        subtitle: t.addbook.manual.subtitle,
        child: const Placeholder(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(t.addbook.title)),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SlotLayout(
          config: <Breakpoint, SlotLayoutConfig>{
            Breakpoints.smallAndUp: SlotLayout.from(
              key: const Key('small_body'),
              builder: (_) => SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.max,
                  children: layout,
                ),
              ),
            ),
            Breakpoints.large: SlotLayout.from(
              key: const Key('large_body'),
              builder: (_) => Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.max,
                children: layout.map((e) => Expanded(child: e)).toList(),
              ),
            )
          },
        ),
      ),
    );
  }
}

class _ISBNQuerySearch extends StatefulWidget {
  const _ISBNQuerySearch();

  @override
  State<_ISBNQuerySearch> createState() => _ISBNQuerySearchState();
}

class _ISBNQuerySearchState extends State<_ISBNQuerySearch> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  String _isbn = '';
  bool _isValidISBN = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void searchBook() {
    // TODO: Implement book
    throw UnimplementedError();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          BarcodeWidget(
            padding: const EdgeInsets.all(32.0),
            data: _isbn,
            barcode: _isValidISBN ? Barcode.isbn() : Barcode.code128(),
            color: Theme.of(context).colorScheme.onSurface,
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: _controller,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'ISBN',
            ),
            onChanged: (value) {
              setState(() {
                _isValidISBN = false;
                _isbn = value;
              });
              _formKey.currentState?.validate();
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return t.forms.error_empty_field;
              } else if (Barcode.isbn().isValid(value)) {
                setState(() => _isValidISBN = true);
                return null;
              } else {
                return t.forms.error_invalid_format(format: 'ISBN');
              }
            },
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary),
              onPressed: !_isValidISBN
                  ? null // Disable is not a valid ISBN
                  : // Enable on ISBN
                  () {
                      if (_formKey.currentState!.validate()) {
                        searchBook();
                      }
                    },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(t.addbook.openlibrary.submit),
              ))
        ],
      ),
    );
  }
}
