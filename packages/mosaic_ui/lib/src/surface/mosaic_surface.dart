import 'dart:ui' show ImageFilter;

import 'package:flutter/widgets.dart';

import '../theme/mosaic_theme.dart';
import '../tokens/mosaic_tokens.dart';
import 'mosaic_surface_kind.dart';

/// The visual primitive every Mosaic component sits on.
///
/// Pulls background color, radius, elevation, and surface *effects* from
/// [MosaicTokens]. Metro mode renders flat and fully opaque by token
/// contract; Modern adds a subtle shadow; Aurora additionally makes the
/// surface translucent, blurs what is behind it, and draws a hairline
/// edge.
///
/// The glass path costs a [BackdropFilter] and a clip, so it is taken
/// only when the active tokens actually ask for it — see
/// [MosaicEffectTokens.isGlass]. On Metro this widget still resolves to
/// a single [Container], exactly as before.
class MosaicSurface extends StatelessWidget {
  const MosaicSurface({
    super.key,
    this.kind = MosaicSurfaceKind.tile,
    this.active = false,
    this.color,
    this.padding,
    this.alignment,
    this.child,
  });

  final MosaicSurfaceKind kind;

  /// Renders with `surfaceActive` instead of `surface`. Use for selected
  /// pivots, focused tiles, or any "currently chosen" affordance.
  final bool active;

  /// Override the resolved background color. Use sparingly — defaults
  /// come from tokens and should cover the common cases.
  ///
  /// An explicit color is still subject to the mode's opacity token: a
  /// caller-supplied brand color on an Aurora tile should read as tinted
  /// glass, not as an opaque patch punched through the layer.
  final Color? color;

  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry? alignment;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    final effect = tokens.effect;
    final radius = _resolveRadius(tokens);
    final elevation = _resolveElevation(tokens);
    final isOverlay = kind == MosaicSurfaceKind.overlay;
    final opacity = isOverlay ? effect.overlayOpacity : effect.surfaceOpacity;
    final blur = isOverlay ? effect.overlayBlur : effect.surfaceBlur;

    var background = color ?? _resolveColor(tokens);
    if (opacity < 1) {
      background = background.withValues(alpha: background.a * opacity);
    }

    final border = effect.strokeWidth > 0 && effect.strokeOpacity > 0
        ? Border.all(
            color: tokens.color.textPrimary.withValues(
              alpha: effect.strokeOpacity,
            ),
            width: effect.strokeWidth,
          )
        : null;

    final borderRadius = radius == 0 ? null : BorderRadius.circular(radius);

    Widget? body = child;
    if (effect.sheenOpacity > 0) {
      // Light catches the top edge. Painted inside the surface rather
      // than as a border so it fades out instead of ending on a line,
      // and behind the child so it never tints content.
      body = Stack(
        fit: StackFit.passthrough,
        // Non-directional on purpose. Stack's default is
        // AlignmentDirectional.topStart, which asserts on a missing
        // Directionality ancestor — and MosaicSurface is a primitive
        // that must render anywhere, including in tests and tooling
        // that never wrap a WidgetsApp. The sheen is symmetric, so
        // there is nothing for a text direction to decide here.
        alignment: Alignment.topLeft,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(
                        0xFFFFFFFF,
                      ).withValues(alpha: effect.sheenOpacity),
                      const Color(0x00FFFFFF),
                    ],
                    // Falls off fast: a sheen reaching halfway down the
                    // pane reads as a gradient fill, not as reflection.
                    stops: const [0.0, 0.45],
                  ),
                ),
              ),
            ),
          ),
          if (child != null) child!,
        ],
      );
    }

    final container = Container(
      padding: padding,
      alignment: alignment,
      decoration: BoxDecoration(
        color: background,
        borderRadius: borderRadius,
        border: border,
        boxShadow: elevation > 0 ? [_subtleShadow(elevation)] : null,
      ),
      child: body,
    );

    if (blur <= 0) return container;

    // BackdropFilter samples everything painted behind it, so it must be
    // clipped to the surface silhouette or the blur bleeds past the
    // rounded corners into neighbouring tiles.
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: BackdropFilter(
        filter: _backdropFilter(blur, effect.saturation),
        child: container,
      ),
    );
  }

  /// Blur, then push saturation back up.
  ///
  /// Order matters and this is the wrong way round from how it reads:
  /// `compose` applies `inner` first, so the saturation matrix runs on
  /// the raw backdrop and the blur runs on the result. That is what we
  /// want — saturating after blurring would amplify the averaged, muddy
  /// colour rather than the original.
  static ImageFilter _backdropFilter(double blur, double saturation) {
    final blurFilter = ImageFilter.blur(sigmaX: blur, sigmaY: blur);
    if (saturation == 1.0) return blurFilter;
    return ImageFilter.compose(
      outer: blurFilter,
      inner: ColorFilter.matrix(_saturationMatrix(saturation)),
    );
  }

  /// Standard saturation matrix. Luminance coefficients are Rec. 709,
  /// matching what the compositor already uses, so a fully desaturated
  /// result is the same grey the platform would produce.
  static List<double> _saturationMatrix(double s) {
    const lumR = 0.2126;
    const lumG = 0.7152;
    const lumB = 0.0722;
    final r = (1 - s) * lumR;
    final g = (1 - s) * lumG;
    final b = (1 - s) * lumB;
    return <double>[
      r + s, g, b, 0, 0, //
      r, g + s, b, 0, 0, //
      r, g, b + s, 0, 0, //
      0, 0, 0, 1, 0, //
    ];
  }

  Color _resolveColor(MosaicTokens tokens) {
    if (active) return tokens.color.surfaceActive;
    return switch (kind) {
      MosaicSurfaceKind.tile => tokens.color.surface,
      MosaicSurfaceKind.panel => tokens.color.surface,
      MosaicSurfaceKind.overlay => tokens.color.surfaceActive,
      MosaicSurfaceKind.muted => tokens.color.surfaceMuted,
    };
  }

  double _resolveRadius(MosaicTokens tokens) {
    return switch (kind) {
      MosaicSurfaceKind.tile => tokens.radius.tile,
      MosaicSurfaceKind.muted => tokens.radius.tile,
      MosaicSurfaceKind.panel => tokens.radius.panel,
      MosaicSurfaceKind.overlay => tokens.radius.panel,
    };
  }

  double _resolveElevation(MosaicTokens tokens) {
    return switch (kind) {
      MosaicSurfaceKind.tile => tokens.elevation.tile,
      MosaicSurfaceKind.muted => 0,
      MosaicSurfaceKind.panel => tokens.elevation.panel,
      MosaicSurfaceKind.overlay => tokens.elevation.overlay,
    };
  }

  BoxShadow _subtleShadow(double elevation) {
    return BoxShadow(
      color: const Color(0x33000000),
      blurRadius: elevation * 4,
      offset: Offset(0, elevation),
    );
  }
}
