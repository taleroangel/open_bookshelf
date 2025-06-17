import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:flutter/material.dart';
import 'package:open_bookshelf/i18n/translations.g.dart';

class ManualAddSection extends StatelessWidget {
  const ManualAddSection({super.key});

  @override
  Widget build(BuildContext context) {
    /* --- Controllers --- */
    final TextEditingController titleController = TextEditingController();
    final TextEditingController subtitleController = TextEditingController();
    final TextEditingController isbnController = TextEditingController();

    return Column(
      children: [
        Text.rich(TextSpan(children: [
          TextSpan(
            text: "* ",
            style: context.textStyles.labelMedium.copyWith(
              color: context.colors.scheme.primary,
            ),
          ),
          TextSpan(text: t.book.fields.required),
        ])),
        TextField(
          controller: titleController,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            label: Text.rich(TextSpan(children: [
              TextSpan(
                text: "*",
                style: context.textStyles.labelMedium.copyWith(
                  color: context.colors.scheme.primary,
                ),
              ),
              TextSpan(text: t.book.fields.title)
            ])),
          ),
        ),
        TextField(
          controller: subtitleController,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: t.book.fields.subtitle,
          ),
        ),
        TextField(
          controller: isbnController,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            label: Text.rich(TextSpan(children: [
              TextSpan(
                text: "* ",
                style: context.textStyles.labelMedium.copyWith(
                  color: context.colors.scheme.primary,
                ),
              ),
              const TextSpan(text: "ISBN"),
            ])),
          ),
        ),
      ].separatedBy(const SizedBox(height: 12)),
    );
  }
}
