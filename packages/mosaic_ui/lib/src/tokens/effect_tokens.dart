import 'package:flutter/foundation.dart';

/// Surface *effect* tokens: translucency, backdrop blur, and hairline
/// strokes.
///
/// These are deliberately separate from [MosaicElevationTokens]. Elevation
/// answers "how far off the page is this?"; effects answer "what is the
/// surface made of?". Metro's answer is "flat opaque paint" — every field
/// here is zero and the renderer skips the work entirely. Aurora's answer
/// is "a pane of frosted glass", which needs blur, alpha, and an edge.
///
/// Defaults are the Metro answer, so an existing [MosaicTokens] that never
/// mentions effects keeps rendering exactly as before.
@immutable
class MosaicEffectTokens {
  const MosaicEffectTokens({
    this.surfaceBlur = 0,
    this.overlayBlur = 0,
    this.surfaceOpacity = 1.0,
    this.overlayOpacity = 1.0,
    this.strokeWidth = 0,
    this.strokeOpacity = 0,
    this.scrimOpacity = 0.32,
  });

  /// Backdrop blur sigma behind tile / panel surfaces. Zero disables the
  /// [BackdropFilter] altogether — it is not a cheap widget, so the
  /// zero-check matters on a grid of 40 tiles.
  final double surfaceBlur;

  /// Backdrop blur sigma behind overlay surfaces (pushed panels, menus).
  /// Usually heavier than [surfaceBlur] because overlays cover content
  /// that must read as "behind glass", not merely tinted.
  final double overlayBlur;

  /// Alpha multiplier applied to tile / panel background colors.
  final double surfaceOpacity;

  /// Alpha multiplier applied to overlay background colors.
  final double overlayOpacity;

  /// Hairline border width drawn on translucent surfaces. Glass without
  /// an edge reads as a smudge; the stroke is what makes it a pane.
  final double strokeWidth;

  /// Alpha of the hairline stroke, applied over `textPrimary` so it
  /// inverts correctly between light and dark.
  final double strokeOpacity;

  /// Alpha of the dimming scrim painted behind modal overlays.
  final double scrimOpacity;

  /// True when this token set asks for any non-opaque rendering. Lets
  /// widgets take the cheap path without inspecting six fields.
  bool get isGlass => surfaceBlur > 0 || overlayBlur > 0 || surfaceOpacity < 1;

  MosaicEffectTokens copyWith({
    double? surfaceBlur,
    double? overlayBlur,
    double? surfaceOpacity,
    double? overlayOpacity,
    double? strokeWidth,
    double? strokeOpacity,
    double? scrimOpacity,
  }) {
    return MosaicEffectTokens(
      surfaceBlur: surfaceBlur ?? this.surfaceBlur,
      overlayBlur: overlayBlur ?? this.overlayBlur,
      surfaceOpacity: surfaceOpacity ?? this.surfaceOpacity,
      overlayOpacity: overlayOpacity ?? this.overlayOpacity,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      strokeOpacity: strokeOpacity ?? this.strokeOpacity,
      scrimOpacity: scrimOpacity ?? this.scrimOpacity,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MosaicEffectTokens &&
        other.surfaceBlur == surfaceBlur &&
        other.overlayBlur == overlayBlur &&
        other.surfaceOpacity == surfaceOpacity &&
        other.overlayOpacity == overlayOpacity &&
        other.strokeWidth == strokeWidth &&
        other.strokeOpacity == strokeOpacity &&
        other.scrimOpacity == scrimOpacity;
  }

  @override
  int get hashCode => Object.hash(
    surfaceBlur,
    overlayBlur,
    surfaceOpacity,
    overlayOpacity,
    strokeWidth,
    strokeOpacity,
    scrimOpacity,
  );
}
