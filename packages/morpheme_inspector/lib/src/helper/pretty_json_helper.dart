import 'dart:convert';

/// Return pretty json with given [object]
String prettyJson(Object? object, [String defaultValue = '']) {
  if (object == null) return defaultValue;
  if (object is Map && object.isEmpty) return defaultValue;
  try {
    Object? data = object;
    if (data is String) {
      data = json.decode(data);
    }
    var encoder = const JsonEncoder.withIndent("     ");
    return encoder.convert(data);
  } catch (e) {
    return object.toString();
  }
}
