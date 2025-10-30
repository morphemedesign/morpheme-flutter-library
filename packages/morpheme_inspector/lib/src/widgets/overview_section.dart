import 'package:flutter/material.dart';
import 'package:morpheme_inspector/src/extensions/date_time_extensions.dart';
import 'package:morpheme_inspector/src/extensions/inspector_extensions.dart';
import 'package:morpheme_inspector/src/models/inspector.dart';
import 'package:morpheme_inspector/src/widgets/text_item_inspector.dart';

/// Show overview section with given [inspector].
class OverviewSection extends StatelessWidget {
  const OverviewSection({
    super.key,
    required this.inspector,
  });

  final Inspector inspector;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextItemInspector(
          title: 'Curl',
          value: inspector.generateCurlCommand(),
        ),
        const SizedBox(height: 8),
        TextItemInspector(
          title: 'URL',
          value: Uri.decodeFull(inspector.request.url.toString()),
        ),
        const SizedBox(height: 8),
        TextItemInspector(
          title: 'Method',
          value: inspector.request.method,
        ),
        const SizedBox(height: 8),
        TextItemInspector(
          title: 'Status',
          value: inspector.status,
        ),
        const SizedBox(height: 8),
        TextItemInspector(
          title: 'Response',
          value: inspector.response?.status?.toString() ?? '-',
        ),
        const SizedBox(height: 8),
        TextItemInspector(
          title: 'SSL',
          value: inspector.isSSL ? 'Yes' : 'No',
        ),
        const SizedBox(height: 8),
        TextItemInspector(
          title: 'Request Time',
          value: inspector.request.dateTime?.toDateTimeString() ?? '-',
        ),
        const SizedBox(height: 8),
        TextItemInspector(
          title: 'Response Time',
          value: inspector.response?.dateTime?.toDateTimeString() ?? '-',
        ),
        const SizedBox(height: 8),
        TextItemInspector(
          title: 'Duration',
          value: inspector.duration,
        ),
        const SizedBox(height: 8),
        TextItemInspector(
          title: 'Request Size',
          value: inspector.requestSize,
        ),
        const SizedBox(height: 8),
        TextItemInspector(
          title: 'Response Size',
          value: inspector.responseSize,
        ),
        const SizedBox(height: 8),
        TextItemInspector(
          title: 'Total Size',
          value: inspector.totalSize,
        ),
      ],
    );
  }
}
