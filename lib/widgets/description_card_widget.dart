import 'package:flutter/material.dart';

class DescriptionCard extends StatelessWidget {
  const DescriptionCard({
    required this.title,
    required this.subtitle,
    this.child,
    this.dividerHeight,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget? child;
  final double? dividerHeight;
  final EdgeInsetsGeometry padding;
  final CrossAxisAlignment crossAxisAlignment;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin,
      child: Padding(
          padding: padding,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: crossAxisAlignment,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Divider(
                height: dividerHeight,
              ),
              if (child != null) child!
            ],
          )),
    );
  }
}
