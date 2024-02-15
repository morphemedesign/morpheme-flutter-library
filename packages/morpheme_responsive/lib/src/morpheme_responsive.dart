import 'package:flutter/material.dart';
import 'package:morpheme_responsive/src/morpheme_breakpoint.dart';
import 'package:morpheme_responsive/src/morpheme_inherited_breakpoint.dart';

/// The `MorphemeResponsive` class is a widget that provides responsive design capabilities by determining
/// the appropriate breakpoint and text scale factor based on the device's screen size.
class MorphemeResponsive extends StatelessWidget {
  const MorphemeResponsive.builder({
    super.key,
    required this.child,
    required this.breakpoints,
  }) : assert(breakpoints.length > 0);

  final Widget child;
  final List<MorphemeBreakpoint> breakpoints;

  static MorphemeBreakpointsData of(BuildContext context) {
    final MorphemeInheritedBreakpoints? data = context
        .dependOnInheritedWidgetOfExactType<MorphemeInheritedBreakpoints>();
    if (data != null) return data.data;
    throw FlutterError.fromParts(
      <DiagnosticsNode>[
        ErrorSummary(
            'MorphemeResponsive.of() called with a context that does not contain MorphemeResponsive.'),
        ErrorDescription(
            'No Responsive ancestor could be found starting from the context that was passed '
            'to MorphemeResponsive.of(). Place a MorphemeResponsive at the root of the app '
            'or supply a MorphemeResponsive.builder.'),
        context.describeElement('The context used was')
      ],
    );
  }

  /// The function `_getBreakpoint` returns the appropriate `MorphemeBreakpoint` object based on the given
  /// `maxWidth` and a list of breakpoints.
  ///
  /// Args:
  ///   maxWidth (double): The maxWidth parameter is a double value representing the maximum width of a
  /// breakpoint.
  ///   breakpoints (List<MorphemeBreakpoint>): A list of MorphemeBreakpoint objects, which represent different
  /// breakpoints for a responsive design. Each MorphemeBreakpoint object has a start and end value,
  /// indicating the range of widths that the breakpoint applies to.
  ///
  /// Returns:
  ///   a MorphemeBreakpoint object.
  MorphemeBreakpoint _getBreakpoint(
    double maxWidth,
    List<MorphemeBreakpoint> breakpoints,
  ) {
    MorphemeBreakpoint breakpoint = breakpoints.first;
    for (var element in breakpoints) {
      if (maxWidth >= element.start &&
          maxWidth <= (element.end ?? double.infinity)) {
        breakpoint = element;
        break;
      }
    }
    return breakpoint;
  }

  /// The function calculates the text scale factor based on the maximum width and a given breakpoint.
  ///
  /// Args:
  ///   maxWidth (double): The maximum width available for the text.
  ///   breakpoint (MorphemeBreakpoint): The `breakpoint` parameter is an object of type `MorphemeBreakpoint`. It
  /// contains properties such as `textScaleFactor`, `textAutoSize`, `widthDesign`, `minTextScaleFactor`,
  /// and `maxTextScaleFactor`.
  ///
  /// Returns:
  ///   the textScaleFactor.
  double _getTextScaleFactor(
    double maxWidth,
    double maxHeight,
    MorphemeBreakpoint breakpoint,
  ) {
    double textScaleFactor = breakpoint.textScaleFactor;
    if (breakpoint.textAutoSize) {
      final widthRatio = maxWidth / breakpoint.widthDesign;
      final heightRatio = maxHeight / breakpoint.heightDesign;
      textScaleFactor = (widthRatio + heightRatio) / 2;
      final minTextScaleFactor =
          breakpoint.minTextScaleFactor ?? breakpoint.textScaleFactor;
      if (textScaleFactor < minTextScaleFactor) {
        textScaleFactor = minTextScaleFactor;
      } else if (breakpoint.maxTextScaleFactor != null &&
          textScaleFactor > breakpoint.maxTextScaleFactor!) {
        textScaleFactor = breakpoint.maxTextScaleFactor!;
      }
    }
    return textScaleFactor;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return LayoutBuilder(builder: (context, constraint) {
      late Orientation orientation;
      late double maxWidth = 0;
      late double maxHeight = 0;
      if (constraint.maxWidth > constraint.maxHeight) {
        orientation = Orientation.landscape;
        maxWidth = constraint.maxHeight;
        maxHeight = constraint.maxWidth;
      } else {
        orientation = Orientation.portrait;
        maxWidth = constraint.maxWidth;
        maxHeight = constraint.maxHeight;
      }
      final aspecRatio = constraint
          .constrainDimensions(constraint.maxWidth, constraint.maxHeight)
          .aspectRatio;

      final breakpoint = _getBreakpoint(maxWidth, breakpoints);
      final textScaleFactor =
          _getTextScaleFactor(maxWidth, maxHeight, breakpoint);

      return MorphemeInheritedBreakpoints(
        data: MorphemeBreakpointsData(
          orientation: orientation,
          textScaleFactor: textScaleFactor,
          breakpoint: breakpoint,
          mediaQuery: mediaQuery,
          aspectRatio: aspecRatio,
        ),
        child: MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(textScaleFactor),
          ),
          child: Builder(builder: (context) {
            return child;
          }),
        ),
      );
    });
  }
}
