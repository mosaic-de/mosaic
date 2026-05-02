import 'package:flutter/widgets.dart';

import '../theme/mosaic_theme.dart';
import 'mosaic_surface.dart';
import 'mosaic_surface_kind.dart';

/// Container used by [MosaicSurfaceHost] for expanded layers.
///
/// Renders as a panel-kind [MosaicSurface] with the host's collapse
/// affordance available via the inherited [MosaicSurfaceScope]. Use it
/// when pushing onto the expansion stack so the look stays consistent
/// across surfaces.
class MosaicPanel extends StatelessWidget {
  const MosaicPanel({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    return MosaicSurface(
      kind: MosaicSurfaceKind.overlay,
      padding: padding ?? EdgeInsets.all(tokens.spacing.md),
      child: child,
    );
  }
}
