import 'package:flutter/widgets.dart';

import '../press/mosaic_press_feedback.dart';
import '../theme/mosaic_theme.dart';

/// One option in a [MosaicSegmented].
@immutable
class MosaicSegment<T> {
  const MosaicSegment({required this.value, required this.label, this.glyph});
  final T value;
  final String label;
  final String? glyph;
}

/// Tight, unified single-select control. Use it when a small set of
/// mutually-exclusive options should sit inline as a group — e.g.
/// "Day / Week / Month", "C / F", "Grid / List".
///
/// Differs from [MosaicChip]s in that segments share a single muted
/// background and the selected one paints a sliding accent fill within
/// the same frame.
class MosaicSegmented<T> extends StatelessWidget {
  const MosaicSegmented({
    super.key,
    required this.value,
    required this.segments,
    required this.onChanged,
    this.enabled = true,
  });

  final T? value;
  final List<MosaicSegment<T>> segments;
  final ValueChanged<T>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: tokens.color.surfaceMuted,
        borderRadius: BorderRadius.circular(tokens.radius.pill),
        border: Border.all(color: tokens.color.divider, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final segment in segments)
            _SegmentButton<T>(
              segment: segment,
              selected: segment.value == value,
              enabled: enabled,
              onPressed: onChanged == null
                  ? null
                  : () => onChanged!(segment.value),
            ),
        ],
      ),
    );
  }
}

class _SegmentButton<T> extends StatelessWidget {
  const _SegmentButton({
    required this.segment,
    required this.selected,
    required this.enabled,
    required this.onPressed,
  });

  final MosaicSegment<T> segment;
  final bool selected;
  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    final fg = selected ? tokens.color.textInverse : tokens.color.textPrimary;
    return MosaicPressFeedback(
      onPressed: onPressed,
      enabled: enabled,
      semanticLabel: segment.label,
      child: AnimatedContainer(
        duration: tokens.motion.scaledUpdate,
        curve: tokens.motion.standardCurve,
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spacing.md,
          vertical: tokens.spacing.xs,
        ),
        decoration: BoxDecoration(
          color: selected ? tokens.color.accent : const Color(0x00000000),
          borderRadius: BorderRadius.circular(tokens.radius.pill),
        ),
        child: DefaultTextStyle.merge(
          style: tokens.typography.tileTitle.copyWith(
            color: fg,
            fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
            height: 1,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (segment.glyph != null) ...[
                Text(segment.glyph!),
                SizedBox(width: tokens.spacing.xs),
              ],
              Text(segment.label),
            ],
          ),
        ),
      ),
    );
  }
}
