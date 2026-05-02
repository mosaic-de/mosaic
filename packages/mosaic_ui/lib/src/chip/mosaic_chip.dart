import 'package:flutter/widgets.dart';

import '../press/mosaic_press_feedback.dart';
import '../theme/mosaic_theme.dart';

/// Pill-shaped selectable affordance. Use for filter toggles, category
/// pickers, tag selection — anything where one or more options sit
/// inline and the active one stands out.
///
/// Selected: accent background, inverse-text foreground.
/// Idle: muted surface background, primary text.
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
    final bg = selected ? tokens.color.accent : tokens.color.surfaceMuted;
    final fg = selected ? tokens.color.textInverse : tokens.color.textPrimary;
    final glyphFg = selected
        ? tokens.color.textInverse
        : tokens.color.textSecondary;
    return MosaicPressFeedback(
      onPressed: onPressed,
      enabled: enabled,
      semanticLabel: label,
      child: Container(
        key: const ValueKey<String>('mosaic.chip.surface'),
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spacing.md,
          vertical: tokens.spacing.xs,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(tokens.radius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (glyph != null) ...[
              Text(
                glyph!,
                style: tokens.typography.tileTitle.copyWith(color: glyphFg),
              ),
              SizedBox(width: tokens.spacing.xs),
            ],
            Text(label, style: tokens.typography.tileTitle.copyWith(color: fg)),
          ],
        ),
      ),
    );
  }
}
