import 'package:flutter/widgets.dart';

import '../press/mosaic_press_feedback.dart';
import '../surface/mosaic_surface.dart';
import '../surface/mosaic_surface_kind.dart';
import 'mosaic_tile_size.dart';
import 'mosaic_tile_widget.dart';

/// Static tile. Composes [MosaicSurface] + [MosaicPressFeedback] +
/// internal frame, exposing the body as [child].
///
/// This is the right primitive when a tile's content is fixed; for
/// stream-driven content reach for `MosaicLiveTile`.
class MosaicTile extends StatelessWidget implements MosaicTileWidget {
  const MosaicTile({
    super.key,
    required this.size,
    this.child,
    this.onPressed,
    this.onLongPress,
    this.enabled = true,
    this.kind = MosaicSurfaceKind.tile,
    this.active = false,
    this.padding,
    this.semanticLabel,
    this.semanticHint,
  });

  @override
  final MosaicTileSize size;

  final Widget? child;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final bool enabled;
  final MosaicSurfaceKind kind;
  final bool active;
  final EdgeInsetsGeometry? padding;
  final String? semanticLabel;
  final String? semanticHint;

  @override
  Widget build(BuildContext context) {
    return MosaicPressFeedback(
      onPressed: onPressed,
      onLongPress: onLongPress,
      enabled: enabled,
      semanticLabel: semanticLabel,
      semanticHint: semanticHint,
      child: MosaicSurface(
        kind: kind,
        active: active,
        padding: padding,
        child: child,
      ),
    );
  }
}
