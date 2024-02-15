import 'package:flutter/material.dart';
import 'package:morpheme_responsive/src/morpheme_inherited_breakpoint.dart';
import 'package:morpheme_responsive/src/morpheme_responsive.dart';

extension MorphemeResponsiveContextExtension on BuildContext {
  MorphemeBreakpointsData get responsive => MorphemeResponsive.of(this);
  bool get isMobile => responsive.isMobile();
  bool get isTablet => responsive.isTablet();
  bool get isDesktop => responsive.isDesktop();
  double responsiveValue({
    required double mobile,
    double? tablet,
    double? desktop,
  }) =>
      responsive.responsiveValue(
        mobile: mobile,
        tablet: tablet,
        desktop: desktop,
      );
}
