import 'package:collection/collection.dart';

enum JsonStatus {
  passed,
  failed,
  skipped,
  ambiguous;

  static JsonStatus fromString(String status) =>
      JsonStatus.values.firstWhereOrNull((e) => e.name == status) ??
      JsonStatus.ambiguous;
}
