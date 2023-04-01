import 'package:flutter/material.dart';
import 'package:open_bookshelf/providers/sideview_provider.dart';
import 'package:provider/provider.dart';

/// Allows [SideviewProvider] to tell when the sideview is enabled or disabled
class SideviewWidget extends StatefulWidget {
  const SideviewWidget({required this.child, super.key});
  final Widget child;

  @override
  State<SideviewWidget> createState() => _SideviewWidgetState();
}

class _SideviewWidgetState extends State<SideviewWidget> {
  late final SideviewProvider provider;

  /// [SideviewProvider] will enable side preview
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      provider = context.read<SideviewProvider>();
      provider.sideviewEnable();
    });
  }

  /// Dispose the widget
  /// [SideviewProvider] will disable side preview
  @override
  void dispose() {
    provider.sideviewDisable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
