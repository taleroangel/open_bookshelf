import 'package:flutter/material.dart';

/// Show an [InteractiveViewer] of an [Image]
class CoverScreen extends StatelessWidget {
  final Widget child;
  const CoverScreen({required this.child, super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Hero(
          tag: "cover:zoom",
          child: Center(
            child: InteractiveViewer(
              constrained: true,
              clipBehavior: Clip.none,
              child: child,
            ),
          ),
        ),
      );
}