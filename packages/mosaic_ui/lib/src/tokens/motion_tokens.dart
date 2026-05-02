import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

/// Motion durations and curves. Every Mosaic transition reads from here —
/// no widget should hardcode a [Duration] or [Curve].
///
/// The [scale] field is a global multiplier applied to all durations.
/// Defaults to 1.0; tests should set it to 0 via `MosaicTheme.test` so
/// animations resolve immediately and golden tests do not flake.
@immutable
class MosaicMotionTokens {
  const MosaicMotionTokens({
    required this.press,
    required this.update,
    required this.expand,
    required this.collapse,
    required this.pivot,
    required this.standardCurve,
    this.scale = 1.0,
  });

  final Duration press;
  final Duration update;
  final Duration expand;
  final Duration collapse;
  final Duration pivot;
  final Curve standardCurve;
  final double scale;

  Duration get scaledPress => _scaled(press);
  Duration get scaledUpdate => _scaled(update);
  Duration get scaledExpand => _scaled(expand);
  Duration get scaledCollapse => _scaled(collapse);
  Duration get scaledPivot => _scaled(pivot);

  Duration _scaled(Duration d) {
    if (scale <= 0) return Duration.zero;
    if (scale == 1.0) return d;
    return Duration(microseconds: (d.inMicroseconds * scale).round());
  }

  MosaicMotionTokens copyWith({
    Duration? press,
    Duration? update,
    Duration? expand,
    Duration? collapse,
    Duration? pivot,
    Curve? standardCurve,
    double? scale,
  }) {
    return MosaicMotionTokens(
      press: press ?? this.press,
      update: update ?? this.update,
      expand: expand ?? this.expand,
      collapse: collapse ?? this.collapse,
      pivot: pivot ?? this.pivot,
      standardCurve: standardCurve ?? this.standardCurve,
      scale: scale ?? this.scale,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MosaicMotionTokens &&
        other.press == press &&
        other.update == update &&
        other.expand == expand &&
        other.collapse == collapse &&
        other.pivot == pivot &&
        other.standardCurve == standardCurve &&
        other.scale == scale;
  }

  @override
  int get hashCode =>
      Object.hash(press, update, expand, collapse, pivot, standardCurve, scale);
}
