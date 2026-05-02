import 'package:flutter/widgets.dart';

import '../press/mosaic_press_feedback.dart';
import '../theme/mosaic_theme.dart';

/// Pill-shaped selectable affordance. Use for filter toggles, category
/// pickers, tag selection — anything where one or more options sit
/// inline and the active one stands out.
///
/// Selected: accent fill, inverse-text foreground, medium weight.
/// Idle: hollow (transparent fill, divider-color border), primary
/// text at regular weight. The shape stays the same — only the fill
/// and weight change — so the row geometry doesn't shift on toggle.
class MosaicChip extends StatelessWidget {
  const MosaicChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onPressed,
    this.glyph,
    this.enabled = true,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;
  final String? glyph;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    final bg = selected ? tokens.color.accent : const Color(0x00000000);
    final borderColor = selected ? tokens.color.accent : tokens.color.divider;
    final fg = selected ? tokens.color.textInverse : tokens.color.textPrimary;
    return MosaicPressFeedback(
      onPressed: onPressed,
      enabled: enabled,
      semanticLabel: label,
      child: AnimatedContainer(
        key: const ValueKey<String>('mosaic.chip.surface'),
        duration: tokens.motion.scaledUpdate,
        curve: tokens.motion.standardCurve,
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spacing.md,
          vertical: tokens.spacing.sm,
        ),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: borderColor, width: 1),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (glyph != null) ...[
                Text(glyph!),
                SizedBox(width: tokens.spacing.xs),
              ],
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
