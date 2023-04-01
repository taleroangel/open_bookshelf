import 'package:flutter/material.dart';

class TextWithIconWidget extends StatelessWidget {
  const TextWithIconWidget({
    required this.icon,
    required this.text,
    super.key,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 16.0),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
        )
      ],
    );
  }
}
