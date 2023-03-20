import 'package:flutter/material.dart';
import 'package:open_bookshelf/providers/book_preview_provider.dart';
import 'package:open_bookshelf/screens/book_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';

/// Show a [BookScreen] at the side of the screen with [AdaptiveScaffold]
/// this widget's lifecycle is attached to [BookPreviewProvider] and defines
/// [BookScreen] behivour
class BookPreviewSideview extends StatefulWidget {
  const BookPreviewSideview({super.key});

  @override
  State<BookPreviewSideview> createState() => _BookPreviewSideviewState();
}

class _BookPreviewSideviewState extends State<BookPreviewSideview> {
  late final BookPreviewProvider provider;

  /// Initialize widget state and allows [BookPreviewProvider] to display books
  /// inside this widget instead of pushing a new [MaterialPageRoute]
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      provider = context.read<BookPreviewProvider>();
      provider.sideviewEnable();
    });
  }

  /// Dispose the widget
  /// [BookPreviewProvider] will now use [MaterialPageRoute] to push a [BookScreen]
  /// instead of showing it inside of this widget
  @override
  void dispose() {
    provider.sideviewDisable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      context.watch<BookPreviewProvider>().sidePreview ?? const BookScreen();
}
