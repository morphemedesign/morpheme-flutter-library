import 'package:flutter/material.dart';

/// Show text item with given [title] and [value].
class TextItemInspector extends StatelessWidget {
  const TextItemInspector({
    super.key,
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: SelectableText(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          flex: 7,
          child: SelectableText(value),
        ),
      ],
    );
  }
}
