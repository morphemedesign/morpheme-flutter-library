import 'package:flutter/material.dart';

import 'morpheme_responsive_target.dart';

/// The `MorphemeBreakpoint` class represents a breakpoint in a responsive design system, with properties
/// such as start and end values, width and height design values, target, text scale factor, and text
/// auto size.
@immutable
class MorphemeBreakpoint {
  const MorphemeBreakpoint({
    required this.start,
    this.end,
    required this.widthDesign,
    required this.heightDesign,
    required this.target,
    this.textScaleFactor = 1,
    this.textAutoSize = false,
    this.minTextScaleFactor,
    this.maxTextScaleFactor,
  });

  const MorphemeBreakpoint.mobile({
    double? start,
    double? end,
    double? widthDesign,
    double? heightDesign,
    this.textScaleFactor = 1,
    this.textAutoSize = true,
    this.minTextScaleFactor,
    this.maxTextScaleFactor,
  })  : start = start ?? 0,
        end = end ?? 599,
        widthDesign = widthDesign ?? 360,
        heightDesign = heightDesign ?? 800,
        target = MorphemeResponsiveTarget.mobile;

  const MorphemeBreakpoint.tablet({
    double? start,
    double? end,
    double? widthDesign,
    double? heightDesign,
    this.textScaleFactor = 1.25,
    this.textAutoSize = true,
    this.minTextScaleFactor,
    this.maxTextScaleFactor,
  })  : start = start ?? 600,
        end = end ?? 1199,
        widthDesign = widthDesign ?? 834,
        heightDesign = heightDesign ?? 1194,
        target = MorphemeResponsiveTarget.tablet;

  const MorphemeBreakpoint.desktop({
    double? start,
    double? end,
    double? widthDesign,
    double? heightDesign,
    this.textScaleFactor = 1.5,
    this.textAutoSize = true,
    this.minTextScaleFactor,
    this.maxTextScaleFactor,
  })  : start = start ?? 1200,
        end = end ?? double.infinity,
        widthDesign = widthDesign ?? 1024,
        heightDesign = heightDesign ?? 1440,
        target = MorphemeResponsiveTarget.desktop;

  final double start;
  final double? end;

  /// width design in potrait mode.
  final double widthDesign;

  /// height design in potrait mode.
  final double heightDesign;
  final String target;
  final double textScaleFactor;
  final bool textAutoSize;
  final double? minTextScaleFactor;
  final double? maxTextScaleFactor;

  MorphemeBreakpoint copyWith({
    double? start,
    double? end,
    double? widthDesign,
    double? heightDesign,
    String? target,
    double? textScaleFactor,
    bool? textAutoSize,
    double? minTextScaleFactor,
    double? maxTextScaleFactor,
  }) {
    return MorphemeBreakpoint(
      start: start ?? this.start,
      end: end ?? this.end,
      widthDesign: widthDesign ?? this.widthDesign,
      heightDesign: heightDesign ?? this.heightDesign,
      target: target ?? this.target,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      textAutoSize: textAutoSize ?? this.textAutoSize,
      minTextScaleFactor: minTextScaleFactor ?? this.minTextScaleFactor,
      maxTextScaleFactor: maxTextScaleFactor ?? this.maxTextScaleFactor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MorphemeBreakpoint &&
        other.start == start &&
        other.end == end &&
        other.widthDesign == widthDesign &&
        other.heightDesign == heightDesign &&
        other.target == target &&
        other.textScaleFactor == textScaleFactor &&
        other.textAutoSize == textAutoSize &&
        other.minTextScaleFactor == minTextScaleFactor &&
        other.maxTextScaleFactor == maxTextScaleFactor;
  }

  @override
  int get hashCode {
    return start.hashCode ^
        end.hashCode ^
        widthDesign.hashCode ^
        heightDesign.hashCode ^
        target.hashCode ^
        textScaleFactor.hashCode ^
        textAutoSize.hashCode ^
        minTextScaleFactor.hashCode ^
        maxTextScaleFactor.hashCode;
  }

  @override
  String toString() {
    return 'MorphemeBreakpoint(start: $start, end: $end, widthDesign: $widthDesign, heightDesign: $heightDesign, target: $target, textScaleFactor: $textScaleFactor, textAutoSize: $textAutoSize, minTextScaleFactor: $minTextScaleFactor, maxTextScaleFactor: $maxTextScaleFactor)';
  }
}
