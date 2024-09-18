import 'package:flutter/material.dart';

extension GEHexString on String {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  Color fromHex({Color defaultColor = Colors.transparent}) {
    if (!RegExp(r'^#?(FF)?(?:[0-9a-fA-F]{3}){1,2}$').hasMatch(this)) {
      return defaultColor;
    }
    final buffer = StringBuffer();
    if (length == 6 || length == 7) buffer.write('ff');
    buffer.write(replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

extension GEHexColor on Color {
  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) =>

      // '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}
