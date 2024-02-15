import 'package:flutter/material.dart';
import 'package:morpheme_responsive/src/morpheme_breakpoint.dart';
import 'package:morpheme_responsive/src/morpheme_responsive_target.dart';

/// The `MorphemeInheritedBreakpoints` class is an immutable inherited widget that provides
/// `MorphemeBreakpointsData` to its descendants.
@immutable
class MorphemeInheritedBreakpoints extends InheritedWidget {
  final MorphemeBreakpointsData data;

  /// Creates a widget that provides [MorphemeBreakpointsData] to its descendants.
  ///
  /// The [data] and [child] arguments must not be null.
  const MorphemeInheritedBreakpoints(
      {super.key, required this.data, required super.child});

  @override
  bool updateShouldNotify(MorphemeInheritedBreakpoints oldWidget) =>
      data != oldWidget.data;
}

/// The `MorphemeBreakpointsData` class represents data related to device breakpoints, orientation, text
/// scaling, and media queries in a Dart application.
@immutable
class MorphemeBreakpointsData {
  const MorphemeBreakpointsData({
    required this.orientation,
    required this.textScaleFactor,
    required this.breakpoint,
    required this.mediaQuery,
    required this.aspectRatio,
  });

  /// The `orientation` property in the `MorphemeBreakpointsData` class represents the
  /// current orientation of the device. It can have two possible values:
  /// `Orientation.portrait` or `Orientation.landscape`. This property is used to
  /// determine the layout and design of the UI based on the device's orientation.
  final Orientation orientation;

  /// The `textScaleFactor` property in the `MorphemeBreakpointsData` class represents the
  /// scaling factor for the text size on the device. It is used to adjust the size of the
  /// text based on the user's preference for larger or smaller text. By multiplying the
  /// base text size with the `textScaleFactor`, the text size can be dynamically adjusted
  /// to accommodate the user's preference.
  final double textScaleFactor;

  /// The `breakpoint` property in the `MorphemeBreakpointsData` class represents the
  /// current breakpoint of the device. A breakpoint is a specific screen width
  /// range at which the layout and design of the UI may need to be adjusted to
  /// provide a better user experience.
  final MorphemeBreakpoint breakpoint;

  /// The `mediaQuery` property in the `MorphemeBreakpointsData` class represents the
  /// current media query data of the device. It provides information about the
  /// device's screen size, pixel density, and other display-related properties.
  /// This information can be used to make responsive design decisions and adapt
  /// the UI layout and design based on the device's capabilities.
  final MediaQueryData mediaQuery;

  /// The `aspectRatio` property in the `MorphemeBreakpointsData` class represents the aspect
  /// ratio of the device's screen. Aspect ratio is the ratio of the width to the height of
  /// the screen. It is used to determine the shape of the screen, whether it is more wide
  /// or more tall.
  final double aspectRatio;

  /// The function checks if the current breakpoint target is mobile.
  bool isMobile() => breakpoint.target == MorphemeResponsiveTarget.mobile;

  /// The function checks if the current breakpoint target is a tablet.
  bool isTablet() => breakpoint.target == MorphemeResponsiveTarget.tablet;

  /// The function checks if the current breakpoint target is desktop.
  bool isDesktop() => breakpoint.target == MorphemeResponsiveTarget.desktop;

  /// The `responsiveValue` function returns a value based on the device type (mobile, tablet, or
  /// desktop), with fallback values for tablet and desktop if not provided.
  ///
  /// Args:
  ///   mobile (double): The `mobile` parameter is a required double value that represents the value to
  /// be returned if the device is a mobile device.
  ///   tablet (double): A double value representing the desired value for tablets. If not provided, the
  /// value of "mobile" will be used instead.
  ///   desktop (double): The `desktop` parameter is an optional double value that represents the
  /// desired value for desktop devices. If not provided, the `mobile` value will be used instead.
  ///
  /// Returns:
  ///   The function `responsiveValue` returns a double value.
  double responsiveValue({
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isTablet()) {
      return tablet ?? mobile;
    } else if (isDesktop()) {
      return desktop ?? mobile;
    }
    return mobile;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MorphemeBreakpointsData &&
        other.orientation == orientation &&
        other.textScaleFactor == textScaleFactor &&
        other.breakpoint == breakpoint &&
        other.mediaQuery == mediaQuery &&
        other.aspectRatio == aspectRatio;
  }

  @override
  int get hashCode {
    return orientation.hashCode ^
        textScaleFactor.hashCode ^
        breakpoint.hashCode ^
        mediaQuery.hashCode ^
        aspectRatio.hashCode;
  }
}
