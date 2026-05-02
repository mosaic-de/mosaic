import 'package:flutter/widgets.dart';

import '../theme/mosaic_theme.dart';

/// AnimatedSwitcher tuned to Mosaic motion tokens.
///
/// Crossfades between children using `motion.update` and the standard
/// curve. Use a stable [Key] on each child to control when transitions
/// fire — same key means no animation (just a rebuild), different key
/// means a crossfade.
///
/// In Mosaic's tile rendering pipeline, this is what swaps the body
/// between value / loading / empty / error views.
class MosaicStateSwitcher extends StatelessWidget {
  const MosaicStateSwitcher({
    super.key,
    required this.child,
    this.alignment = Alignment.center,
  });

  final Widget child;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    return AnimatedSwitcher(
      duration: tokens.motion.scaledUpdate,
      switchInCurve: tokens.motion.standardCurve,
      switchOutCurve: tokens.motion.standardCurve,
      layoutBuilder: (current, previous) {
        return Stack(
          alignment: alignment,
          children: [...previous, if (current != null) current],
        );
      },
      child: child,
    );
  }
}
