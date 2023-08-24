import 'package:flutter/material.dart';
import 'package:open_bookshelf/i18n/translations.g.dart';

/// Show an [Exception] in a [Card] following the [Theme]'s error colors
class ExceptionWidget extends StatelessWidget {
  const ExceptionWidget({required this.exception, super.key});
  final Exception? exception;

  @override
  Widget build(BuildContext context) => Card(
        color: Theme.of(context).colorScheme.onError,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  t.general.misc.exception,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  exception.runtimeType.toString(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
                const SizedBox(
                  height: 16.0,
                ),
                Text(
                  exception.toString(),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      );
}
