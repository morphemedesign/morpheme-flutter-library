import 'package:flutter/material.dart';
import 'package:morpheme_responsive/src/model/morpheme_inherited_breakpoint.dart';
import 'package:morpheme_responsive/src/widget/morpheme_responsive.dart';

extension MorphemeResponsiveContextExtension on BuildContext {
  MorphemeBreakpointsData get responsive => MorphemeResponsive.of(this);
  bool get isMobile => responsive.isMobile();
  bool get isTablet => responsive.isTablet();
  bool get isDesktop => responsive.isDesktop();
  double responsiveValue({
    required double Function(Orientation orientation) mobile,
    double Function(Orientation orientation)? tablet,
    double Function(Orientation orientation)? desktop,
  }) =>
      responsive.responsiveValue(
        mobile: mobile,
        tablet: tablet,
        desktop: desktop,
      );
}
