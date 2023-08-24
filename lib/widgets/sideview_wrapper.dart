import 'package:flutter/material.dart';
import 'package:open_bookshelf/providers/sideview_provider.dart';
import 'package:provider/provider.dart';

/// Allows [SideviewProvider] to tell when the sideview is enabled or disabled
class SideviewWrapper extends StatefulWidget {
  const SideviewWrapper({required this.child, super.key});
  final Widget child;

  @override
  State<SideviewWrapper> createState() => _SideviewWrapperState();
}

class _SideviewWrapperState extends State<SideviewWrapper> {
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
