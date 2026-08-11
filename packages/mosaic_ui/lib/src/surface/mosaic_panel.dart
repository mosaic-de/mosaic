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
///
/// Wraps its body in a [SafeArea] so panel chrome (titles, close
/// affordances, list rows) never lands under the status bar / nav bar
/// or notch — even when the host activity is rendered edge-to-edge.
class MosaicPanel extends StatelessWidget {
  const MosaicPanel({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    // Use viewPadding (the unconsumed system insets) instead of
    // SafeArea — when the host activity is edge-to-edge with a
    // transparent SystemUiOverlayStyle, MediaQuery.padding is
    // sometimes reported as 0 and SafeArea silently no-ops. viewPadding
    // is always the raw status-bar / nav-bar dimensions, so the inset
    // applies regardless of overlay transparency.
    final view = MediaQuery.viewPaddingOf(context);
    return MosaicSurface(
      kind: MosaicSurfaceKind.overlay,
      padding: padding ?? EdgeInsets.all(tokens.spacing.md),
      child: Padding(
        padding: EdgeInsets.only(
          top: view.top,
          bottom: view.bottom,
          left: view.left,
          right: view.right,
        ),
        child: child,
      ),
    );
  }
}
