import 'package:flutter/material.dart';
import 'package:morpheme_inspector/src/helper/pretty_json_helper.dart';
import 'package:morpheme_inspector/src/models/inspector.dart';
import 'package:morpheme_inspector/src/widgets/body_inspector.dart';
import 'package:morpheme_inspector/src/widgets/text_item_inspector.dart';

/// Show response section with given [inspector].
class ResponseSection extends StatelessWidget {
  const ResponseSection({
    super.key,
    required this.inspector,
  });

  final Inspector inspector;

  @override
  Widget build(BuildContext context) {
    final headers = <Widget>[];
    inspector.response?.headers?.forEach(
      (key, value) {
        headers.add(
          Column(
            children: [
              TextItemInspector(
                title: key,
                value: value,
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    String body = prettyJson(inspector.response?.body);

    if (inspector.response?.isTimeout ?? false) {
      return const Center(
        child: Text('Response is timeout'),
      );
    }

    if (inspector.response == null || (headers.isEmpty && body.isEmpty)) {
      return const Center(
        child: Text('Response is empty'),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...headers,
        if (body.isNotEmpty)
          BodyInspector(
            title: 'Body',
            value: body,
          ),
      ],
    );
  }
}
