import 'package:flutter/material.dart';
import 'package:morpheme_responsive/src/widget/morpheme_responsive.dart';

typedef BuilderResposive = Widget Function(
  BuildContext context,
  Orientation orientation,
);

class MorphemeResponsiveWidget extends StatelessWidget {
  const MorphemeResponsiveWidget({
    super.key,
    required this.builderMobile,
    this.builderTablet,
    this.builderDekstop,
  });

  const MorphemeResponsiveWidget.builder({
    super.key,
    required BuilderResposive builder,
  })  : builderMobile = builder,
        builderTablet = builder,
        builderDekstop = builder;

  final BuilderResposive builderMobile;
  final BuilderResposive? builderTablet;
  final BuilderResposive? builderDekstop;

  @override
  Widget build(BuildContext context) {
    final responsive = MorphemeResponsive.of(context);

    if (responsive.isTablet() && builderTablet != null) {
      return builderTablet!.call(context, responsive.orientation);
    } else if (responsive.isDesktop() && builderDekstop != null) {
      return builderDekstop!.call(context, responsive.orientation);
    }
    return builderMobile.call(context, responsive.orientation);
  }
}
