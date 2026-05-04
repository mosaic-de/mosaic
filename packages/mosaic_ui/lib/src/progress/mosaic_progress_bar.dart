import 'package:flutter/widgets.dart';

import '../theme/mosaic_theme.dart';

/// Linear determinate progress. Renders a flat track + accent fill.
/// Indeterminate variants live on [MosaicActivityIndicator] — this
/// widget assumes a known [value] in `[0, 1]`.
///
/// In Metro the bar is sharp; in Modern it picks up the input radius.
class MosaicProgressBar extends StatelessWidget {
  const MosaicProgressBar({
    super.key,
    required this.value,
    this.height = 4,
    this.color,
    this.trackColor,
  }) : assert(value >= 0 && value <= 1, 'value must be in [0, 1]');

  final double value;
  final double height;

  /// Override fill color. Defaults to [MosaicColorTokens.accent].
  final Color? color;

  /// Override track color. Defaults to [MosaicColorTokens.surfaceActive].
  final Color? trackColor;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    final radius = BorderRadius.circular(
      tokens.isMetro ? 0 : (height / 2),
    );
    final fill = color ?? tokens.color.accent;
    final track = trackColor ?? tokens.color.surfaceActive;
    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: track)),
            FractionallySizedBox(
              widthFactor: value,
              child: ColoredBox(color: fill),
            ),
          ],
        ),
      ),
    );
  }
}
