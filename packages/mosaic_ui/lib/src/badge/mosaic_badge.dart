import 'package:flutter/widgets.dart';

import '../theme/mosaic_theme.dart';

/// Badge tone. Maps to a token color; consumers should not pass a raw
/// color unless overriding for a specific brand context.
enum MosaicBadgeTone { neutral, accent, error, warning, success, info }

/// Compact status pill. Two flavors:
/// - [MosaicBadge] with a [label] renders a small filled pill.
/// - [MosaicBadge.dot] renders a single colored dot for unread/online
///   indicators on tiles or avatars.
///
/// Sizing follows the system spacing scale, not arbitrary px values.
class MosaicBadge extends StatelessWidget {
  const MosaicBadge({
    super.key,
    required this.label,
    this.tone = MosaicBadgeTone.accent,
    this.color,
    this.foreground,
  }) : _isDot = false;

  /// Indicator dot. No label, fixed 8x8 in design tokens.
  const MosaicBadge.dot({
    super.key,
    this.tone = MosaicBadgeTone.accent,
    this.color,
  }) : label = '',
       foreground = null,
       _isDot = true;

  final String label;
  final MosaicBadgeTone tone;
  final Color? color;
  final Color? foreground;
  final bool _isDot;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    final fill = color ?? _toneColor(context, tone);
    if (_isDot) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(tokens.radius.pill.toDouble()),
        ),
      );
    }
    final text = foreground ?? _toneForeground(context, tone);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.sm,
        vertical: tokens.spacing.xs / 2,
      ),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(tokens.radius.pill.toDouble()),
      ),
      child: Text(
        label,
        style: tokens.typography.caption.copyWith(
          color: text,
          fontWeight: FontWeight.w500,
          height: 1,
        ),
      ),
    );
  }

  static Color _toneColor(BuildContext context, MosaicBadgeTone tone) {
    final tokens = MosaicTheme.of(context);
    return switch (tone) {
      MosaicBadgeTone.neutral => tokens.color.surfaceActive,
      MosaicBadgeTone.accent => tokens.color.accent,
      MosaicBadgeTone.error => tokens.color.error,
      MosaicBadgeTone.warning => tokens.color.warning,
      MosaicBadgeTone.success => tokens.color.success,
      MosaicBadgeTone.info => tokens.color.textSecondary,
    };
  }

  static Color _toneForeground(BuildContext context, MosaicBadgeTone tone) {
    final tokens = MosaicTheme.of(context);
    return switch (tone) {
      MosaicBadgeTone.neutral => tokens.color.textPrimary,
      MosaicBadgeTone.accent => tokens.color.textInverse,
      MosaicBadgeTone.error => tokens.color.textInverse,
      MosaicBadgeTone.warning => tokens.color.textInverse,
      MosaicBadgeTone.success => tokens.color.textInverse,
      MosaicBadgeTone.info => tokens.color.textInverse,
    };
  }
}
