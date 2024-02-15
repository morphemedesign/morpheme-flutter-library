import 'package:flutter/material.dart';

/// Body widget for show [title] and [value].
class BodyInspector extends StatelessWidget {
  const BodyInspector({
    super.key,
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        SelectableText(value),
      ],
    );
  }
}
