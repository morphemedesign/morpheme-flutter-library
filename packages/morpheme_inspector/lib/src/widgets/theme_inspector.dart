import 'package:flutter/material.dart';

/// Default theme inspector with dark mode.
class ThemeInspector extends StatelessWidget {
  const ThemeInspector({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: child,
    );
  }
}
