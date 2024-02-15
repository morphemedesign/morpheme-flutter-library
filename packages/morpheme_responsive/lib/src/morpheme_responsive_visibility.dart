import 'package:flutter/material.dart';
import 'package:morpheme_responsive/src/morpheme_responsive.dart';

/// The `MorphemeResponsiveVisibility` class is a widget that conditionally shows or hides its child based
/// on the device's screen size.
class MorphemeResponsiveVisibility extends StatelessWidget {
  const MorphemeResponsiveVisibility({
    super.key,
    required this.child,
    this.replacement = const SizedBox.shrink(),
    this.mobile = false,
    this.tablet = false,
    this.desktop = false,
    this.maintainState = false,
    this.maintainAnimation = false,
    this.maintainSize = false,
    this.maintainSemantics = false,
    this.maintainInteractivity = false,
  });

  final Widget child;
  final Widget replacement;
  final bool mobile;
  final bool tablet;
  final bool desktop;
  final bool maintainState;
  final bool maintainAnimation;
  final bool maintainSize;
  final bool maintainSemantics;
  final bool maintainInteractivity;

  @override
  Widget build(BuildContext context) {
    final responsive = MorphemeResponsive.of(context);
    bool visible = false;

    if ((responsive.isMobile() && mobile) ||
        (responsive.isTablet() && tablet) ||
        (responsive.isDesktop() && desktop)) {
      visible = true;
    }

    return Visibility(
      visible: visible,
      replacement: replacement,
      maintainState: maintainState,
      maintainAnimation: maintainAnimation,
      maintainSize: maintainSize,
      maintainSemantics: maintainSemantics,
      maintainInteractivity: maintainInteractivity,
      child: child,
    );
  }
}
