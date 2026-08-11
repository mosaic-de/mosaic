import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../mode/mosaic_mode.dart';
import 'color_tokens.dart';
import 'effect_tokens.dart';
import 'elevation_tokens.dart';
import 'grid_tokens.dart';
import 'motion_tokens.dart';
import 'radius_tokens.dart';
import 'spacing_tokens.dart';
import 'typography_tokens.dart';

/// Umbrella token bundle. A single [MosaicTokens] instance carries every
/// visual decision a component needs. Components must not reach for any
/// other source of style values.
@immutable
class MosaicTokens {
  const MosaicTokens({
    required this.mode,
    required this.brightness,
    required this.color,
    required this.spacing,
    required this.radius,
    required this.elevation,
    required this.motion,
    required this.grid,
    required this.typography,
    this.effect = const MosaicEffectTokens(),
  });

  /// Default Metro tokens. Flat surfaces, sharp radii, snappy motion.
  factory MosaicTokens.metro({
    Brightness brightness = Brightness.dark,
    double motionScale = 1.0,
  }) {
    final color = brightness == Brightness.dark
        ? _metroDarkColors
        : _metroLightColors;
    return MosaicTokens(
      mode: MosaicMode.metro,
      brightness: brightness,
      color: color,
      spacing: const MosaicSpacingTokens(),
      radius: const MosaicRadiusTokens(tile: 0, panel: 0, pill: 999, input: 2),
      elevation: const MosaicElevationTokens(tile: 0, panel: 0, overlay: 0),
      motion: MosaicMotionTokens(
        press: const Duration(milliseconds: 80),
        update: const Duration(milliseconds: 120),
        expand: const Duration(milliseconds: 180),
        collapse: const Duration(milliseconds: 160),
        pivot: const Duration(milliseconds: 200),
        standardCurve: Curves.easeOut,
        scale: motionScale,
      ),
      grid: const MosaicGridTokens(),
      typography: _typography,
    );
  }

  /// Default Modern tokens. Softer radii, subtle elevation, gentler motion.
  /// Still strict grid; never approaches Material density.
  factory MosaicTokens.modern({
    Brightness brightness = Brightness.dark,
    double motionScale = 1.0,
  }) {
    final color = brightness == Brightness.dark
        ? _modernDarkColors
        : _modernLightColors;
    return MosaicTokens(
      mode: MosaicMode.modern,
      brightness: brightness,
      color: color,
      spacing: const MosaicSpacingTokens(),
      radius: const MosaicRadiusTokens(
        tile: 12,
        panel: 16,
        pill: 999,
        input: 10,
      ),
      elevation: const MosaicElevationTokens(tile: 1, panel: 2, overlay: 4),
      motion: MosaicMotionTokens(
        press: const Duration(milliseconds: 120),
        update: const Duration(milliseconds: 180),
        expand: const Duration(milliseconds: 240),
        collapse: const Duration(milliseconds: 220),
        pivot: const Duration(milliseconds: 260),
        standardCurve: Curves.easeInOutCubic,
        scale: motionScale,
      ),
      grid: const MosaicGridTokens(),
      typography: _typography,
    );
  }

  /// Aurora tokens. Layered translucent panes over the backdrop: large
  /// radii, genuine elevation, backdrop blur, hairline edges, and longer
  /// decelerating motion.
  ///
  /// Aurora is the only mode whose surfaces are not opaque, so it is the
  /// only one that costs a [BackdropFilter] per surface. Everything
  /// structural — grid columns, tile spans, spacing scale — is unchanged
  /// from Metro on purpose: swapping mode must never reflow a layout.
  factory MosaicTokens.aurora({
    Brightness brightness = Brightness.dark,
    double motionScale = 1.0,
  }) {
    final color = brightness == Brightness.dark
        ? _auroraDarkColors
        : _auroraLightColors;
    return MosaicTokens(
      mode: MosaicMode.aurora,
      brightness: brightness,
      color: color,
      spacing: const MosaicSpacingTokens(),
      radius: const MosaicRadiusTokens(
        tile: 20,
        panel: 28,
        pill: 999,
        input: 14,
      ),
      elevation: const MosaicElevationTokens(tile: 2, panel: 8, overlay: 16),
      effect: MosaicEffectTokens(
        surfaceBlur: 18,
        overlayBlur: 32,
        surfaceOpacity: brightness == Brightness.dark ? 0.62 : 0.72,
        overlayOpacity: brightness == Brightness.dark ? 0.80 : 0.88,
        strokeWidth: 1,
        // Dark glass needs a brighter edge to separate from the backdrop;
        // light glass needs a fainter one or the hairline reads as a border.
        strokeOpacity: brightness == Brightness.dark ? 0.12 : 0.07,
        scrimOpacity: 0.44,
      ),
      motion: MosaicMotionTokens(
        press: const Duration(milliseconds: 140),
        update: const Duration(milliseconds: 220),
        expand: const Duration(milliseconds: 320),
        collapse: const Duration(milliseconds: 280),
        pivot: const Duration(milliseconds: 300),
        // Strong deceleration reads as weight settling — the motion
        // counterpart of the mode's visible depth.
        standardCurve: Curves.easeOutCubic,
        scale: motionScale,
      ),
      // Wider gutters and margin: translucent panes need air between them
      // or the blurred edges bleed into each other and the depth reads as
      // mush. Column counts stay at the Metro values — structure is not a
      // mode concern.
      grid: const MosaicGridTokens(margin: 20, gutter: 12),
      typography: _typography,
    );
  }

  final MosaicMode mode;
  final Brightness brightness;
  final MosaicColorTokens color;
  final MosaicSpacingTokens spacing;
  final MosaicRadiusTokens radius;
  final MosaicElevationTokens elevation;
  final MosaicMotionTokens motion;
  final MosaicGridTokens grid;
  final MosaicTypographyTokens typography;
  final MosaicEffectTokens effect;

  bool get isMetro => mode == MosaicMode.metro;
  bool get isModern => mode == MosaicMode.modern;
  bool get isAurora => mode == MosaicMode.aurora;
  bool get isDark => brightness == Brightness.dark;
  bool get isLight => brightness == Brightness.light;

  /// Stable lowercase identifier for the active mode. Used by debug
  /// overlays and by apps persisting the user's choice.
  String get modeName => mode.name;

  MosaicTokens copyWith({
    MosaicMode? mode,
    Brightness? brightness,
    MosaicColorTokens? color,
    MosaicSpacingTokens? spacing,
    MosaicRadiusTokens? radius,
    MosaicElevationTokens? elevation,
    MosaicMotionTokens? motion,
    MosaicGridTokens? grid,
    MosaicTypographyTokens? typography,
    MosaicEffectTokens? effect,
  }) {
    return MosaicTokens(
      mode: mode ?? this.mode,
      brightness: brightness ?? this.brightness,
      color: color ?? this.color,
      spacing: spacing ?? this.spacing,
      radius: radius ?? this.radius,
      elevation: elevation ?? this.elevation,
      motion: motion ?? this.motion,
      grid: grid ?? this.grid,
      typography: typography ?? this.typography,
      effect: effect ?? this.effect,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MosaicTokens &&
        other.mode == mode &&
        other.brightness == brightness &&
        other.color == color &&
        other.spacing == spacing &&
        other.radius == radius &&
        other.elevation == elevation &&
        other.motion == motion &&
        other.grid == grid &&
        other.typography == typography &&
        other.effect == effect;
  }

  @override
  int get hashCode => Object.hash(
    mode,
    brightness,
    color,
    spacing,
    radius,
    elevation,
    motion,
    grid,
    typography,
    effect,
  );
}

const MosaicColorTokens _metroDarkColors = MosaicColorTokens(
  background: Color(0xFF0B0B0C),
  surface: Color(0xFF121214),
  surfaceActive: Color(0xFF1A1A1F),
  surfaceMuted: Color(0xFF09090A),
  textPrimary: Color(0xFFFFFFFF),
  textSecondary: Color(0xFFA1A1AA),
  textInverse: Color(0xFF0B0B0C),
  accent: Color(0xFF00B7C3),
  error: Color(0xFFEF4444),
  warning: Color(0xFFF59E0B),
  success: Color(0xFF10B981),
  divider: Color(0xFF27272A),
);

const MosaicColorTokens _metroLightColors = MosaicColorTokens(
  background: Color(0xFFFFFFFF),
  surface: Color(0xFFF4F4F5),
  surfaceActive: Color(0xFFE4E4E7),
  surfaceMuted: Color(0xFFFAFAFA),
  textPrimary: Color(0xFF0B0B0C),
  textSecondary: Color(0xFF52525B),
  textInverse: Color(0xFFFFFFFF),
  accent: Color(0xFF0891B2),
  error: Color(0xFFDC2626),
  warning: Color(0xFFD97706),
  success: Color(0xFF059669),
  divider: Color(0xFFE4E4E7),
);

const MosaicColorTokens _modernDarkColors = MosaicColorTokens(
  background: Color(0xFF0E0E12),
  surface: Color(0xFF17171C),
  surfaceActive: Color(0xFF22222A),
  surfaceMuted: Color(0xFF0B0B0F),
  textPrimary: Color(0xFFF4F4F5),
  textSecondary: Color(0xFFA1A1AA),
  textInverse: Color(0xFF0E0E12),
  accent: Color(0xFF22D3EE),
  error: Color(0xFFF87171),
  warning: Color(0xFFFBBF24),
  success: Color(0xFF34D399),
  divider: Color(0xFF2A2A33),
);

const MosaicColorTokens _modernLightColors = MosaicColorTokens(
  background: Color(0xFFFAFAFA),
  surface: Color(0xFFFFFFFF),
  surfaceActive: Color(0xFFF4F4F5),
  surfaceMuted: Color(0xFFF7F7F8),
  textPrimary: Color(0xFF18181B),
  textSecondary: Color(0xFF52525B),
  textInverse: Color(0xFFFFFFFF),
  accent: Color(0xFF0E7490),
  error: Color(0xFFDC2626),
  warning: Color(0xFFD97706),
  success: Color(0xFF059669),
  divider: Color(0xFFE4E4E7),
);

// Aurora leans violet rather than Metro's teal so the two modes are
// distinguishable at a glance even in a screenshot with no chrome.
const MosaicColorTokens _auroraDarkColors = MosaicColorTokens(
  background: Color(0xFF08080C),
  surface: Color(0xFF16161E),
  surfaceActive: Color(0xFF23232E),
  surfaceMuted: Color(0xFF101016),
  textPrimary: Color(0xFFF7F7FA),
  textSecondary: Color(0xFF9E9EAE),
  textInverse: Color(0xFF08080C),
  accent: Color(0xFF7C6CFF),
  error: Color(0xFFFF6B6B),
  warning: Color(0xFFFFB454),
  success: Color(0xFF4ADE80),
  divider: Color(0xFF2C2C38),
);

const MosaicColorTokens _auroraLightColors = MosaicColorTokens(
  background: Color(0xFFF6F6FA),
  surface: Color(0xFFFFFFFF),
  surfaceActive: Color(0xFFEDEDF5),
  surfaceMuted: Color(0xFFF0F0F6),
  textPrimary: Color(0xFF14141A),
  textSecondary: Color(0xFF5B5B6B),
  textInverse: Color(0xFFFFFFFF),
  accent: Color(0xFF5B4BD6),
  error: Color(0xFFDC2626),
  warning: Color(0xFFD97706),
  success: Color(0xFF059669),
  divider: Color(0xFFE2E2EC),
);

const MosaicTypographyTokens _typography = MosaicTypographyTokens(
  display: TextStyle(
    fontSize: 56,
    height: 1.05,
    fontWeight: FontWeight.w300,
    letterSpacing: -1.2,
  ),
  headline: TextStyle(
    fontSize: 34,
    height: 1.1,
    fontWeight: FontWeight.w300,
    letterSpacing: -0.6,
  ),
  title: TextStyle(
    fontSize: 22,
    height: 1.2,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.2,
  ),
  body: TextStyle(fontSize: 15, height: 1.4, fontWeight: FontWeight.w400),
  caption: TextStyle(
    fontSize: 12,
    height: 1.3,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
  ),
  metric: TextStyle(
    fontSize: 28,
    height: 1.1,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.4,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  ),
  tileTitle: TextStyle(
    fontSize: 14,
    height: 1.2,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  ),
  tileSubtitle: TextStyle(
    fontSize: 12,
    height: 1.25,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
  ),
);
