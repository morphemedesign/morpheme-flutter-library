import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
        Row(
          children: [
            Expanded(
              child: SelectableText(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            IconButton(
              onPressed: () => Clipboard.setData(ClipboardData(text: value)),
              iconSize: 16,
              icon: Icon(Icons.copy),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SelectableText(value),
      ],
    );
  }
}
