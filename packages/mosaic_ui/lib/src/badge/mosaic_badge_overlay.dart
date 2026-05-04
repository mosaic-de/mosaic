import 'package:flutter/widgets.dart';

import '../theme/mosaic_theme.dart';
import 'mosaic_badge.dart';

/// Where to anchor a [MosaicBadgeOverlay]'s badge relative to its child.
enum MosaicBadgePosition { topRight, topLeft, bottomRight, bottomLeft }

/// Stacks a [MosaicBadge] over [child], typically used to show an
/// unread count over an icon, an avatar, or a tile.
///
/// For a label-style badge pass [count] (auto-formatted, hides when
/// `count == 0` unless [showWhenZero] is set) or [label] for arbitrary
/// text. Pass neither and the overlay degenerates to [MosaicBadge.dot]
/// for a "something here" indicator.
class MosaicBadgeOverlay extends StatelessWidget {
  const MosaicBadgeOverlay({
    super.key,
    required this.child,
    this.count,
    this.label,
    this.tone = MosaicBadgeTone.error,
    this.position = MosaicBadgePosition.topRight,
    this.showWhenZero = false,
    this.maxCount = 99,
  });

  final Widget child;
  final int? count;
  final String? label;
  final MosaicBadgeTone tone;
  final MosaicBadgePosition position;

  /// When true, a `count` of zero still renders the badge.
  final bool showWhenZero;

  /// Caps the displayed value at `<max>+`. Set high to disable.
  final int maxCount;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    final badge = _buildBadge();
    if (badge == null) return child;
    final offset = -tokens.spacing.xs;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: position == MosaicBadgePosition.topRight ||
                  position == MosaicBadgePosition.topLeft
              ? offset
              : null,
          bottom: position == MosaicBadgePosition.bottomRight ||
                  position == MosaicBadgePosition.bottomLeft
              ? offset
              : null,
          left: position == MosaicBadgePosition.topLeft ||
                  position == MosaicBadgePosition.bottomLeft
              ? offset
              : null,
          right: position == MosaicBadgePosition.topRight ||
                  position == MosaicBadgePosition.bottomRight
              ? offset
              : null,
          child: badge,
        ),
      ],
    );
  }

  Widget? _buildBadge() {
    if (label != null) {
      return MosaicBadge(label: label!, tone: tone);
    }
    if (count != null) {
      final value = count!;
      if (value == 0 && !showWhenZero) return null;
      final shown = value > maxCount ? '$maxCount+' : '$value';
      return MosaicBadge(label: shown, tone: tone);
    }
    return MosaicBadge.dot(tone: tone);
  }
}
