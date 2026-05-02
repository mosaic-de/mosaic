import 'package:flutter/widgets.dart';

import '../theme/mosaic_theme.dart';
import '../tokens/mosaic_tokens.dart';
import 'mosaic_surface_kind.dart';

/// The visual primitive every Mosaic component sits on.
///
/// Pulls background color, radius, and elevation from [MosaicTokens].
/// Metro mode renders flat (zero elevation) by token contract; Modern
/// mode adds a subtle shadow scaled to elevation tokens.
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
  final Color? color;

  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry? alignment;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    final background = color ?? _resolveColor(tokens);
    final radius = _resolveRadius(tokens);
    final elevation = _resolveElevation(tokens);

    return Container(
      padding: padding,
      alignment: alignment,
      decoration: BoxDecoration(
        color: background,
        borderRadius: radius == 0 ? null : BorderRadius.circular(radius),
        boxShadow: elevation > 0 ? [_subtleShadow(elevation)] : null,
      ),
      child: child,
    );
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
