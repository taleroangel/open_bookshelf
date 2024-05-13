import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:flutter/material.dart';

class ListInputWidget<S> extends StatelessWidget {
  final List<S> items;
  final String label;
  final S Function(String value) parseValue;
  final void Function(List<S> items) onUpdate;
  final void Function(S item) onRemove;

  const ListInputWidget({
    required this.items,
    required this.label,
    required this.parseValue,
    required this.onUpdate,
    required this.onRemove,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: label,
                ),
              ),
            ),
            FloatingActionButton(
              onPressed: () {
                // Get the value
                final S value = parseValue(controller.text);
                // Call update
                onUpdate.call([value, ...items]);
              },
              child: const Icon(Icons.add),
            ),
          ].separatedBy(
            const SizedBox(width: 12.0),
          ),
        ),
        if (items.isNotEmpty)
          Column(
            children: items
                .map(
                  (e) => Row(
                    children: [
                      IconButton(
                        onPressed: () => onRemove(e),
                        icon: const Icon(Icons.close_rounded),
                      ),
                      Text(e.toString()),
                    ].separatedBy(const SizedBox(width: 8.0)),
                  ),
                )
                .toList(),
          ),
      ].separatedBy(
        const SizedBox(height: 16.0),
      ),
    );
  }
}
