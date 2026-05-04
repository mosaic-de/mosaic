import 'package:flutter/widgets.dart';

import '../press/mosaic_press_feedback.dart';
import '../theme/mosaic_theme.dart';

/// Token-driven 1-N rating input. Default uses 5 stars; override
/// [count] for other scales (1–3 dots, 1–10 etc).
///
/// Tap a glyph to set the rating. Tapping the active rating again
/// keeps it (does not reset to 0). Set `value: 0` to start unrated;
/// the consumer can choose whether re-tapping clears.
class MosaicRating extends StatelessWidget {
  const MosaicRating({
    super.key,
    required this.value,
    required this.onChanged,
    this.count = 5,
    this.glyph = '★',
    this.emptyGlyph = '☆',
    this.size = 28,
    this.enabled = true,
  }) : assert(count > 0, 'count must be positive'),
       assert(value >= 0 && value <= count, 'value out of range');

  final int value;
  final ValueChanged<int>? onChanged;
  final int count;
  final String glyph;
  final String emptyGlyph;
  final double size;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= count; i++)
          MosaicPressFeedback(
            onPressed: enabled ? () => onChanged?.call(i) : null,
            enabled: enabled,
            semanticLabel: '$i of $count',
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                i <= value ? glyph : emptyGlyph,
                style: TextStyle(
                  fontSize: size,
                  height: 1,
                  color: i <= value
                      ? tokens.color.accent
                      : tokens.color.textSecondary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
