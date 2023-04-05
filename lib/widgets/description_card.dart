import 'package:flutter/material.dart';

class DescriptionCard extends StatelessWidget {
  const DescriptionCard({
    required this.title,
    required this.subtitle,
    this.child,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Divider(),
              if (child != null) child!
            ],
          )),
    );
  }
}
