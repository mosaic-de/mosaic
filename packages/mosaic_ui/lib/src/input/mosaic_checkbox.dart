import 'package:flutter/widgets.dart';

import '../press/mosaic_press_feedback.dart';
import '../theme/mosaic_theme.dart';

/// A token-driven checkbox with an optional label.
///
/// When [label] is supplied, the whole row is the tap target. Without
/// a label, only the box itself responds.
class MosaicCheckbox extends StatelessWidget {
  const MosaicCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.enabled = true,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final bool enabled;

  void _toggle() => onChanged?.call(!value);

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    final box = _Box(value: value, enabled: enabled);
    if (label == null) {
      return MosaicPressFeedback(
        onPressed: enabled ? _toggle : null,
        enabled: enabled,
        semanticLabel: 'Checkbox',
        child: Padding(padding: EdgeInsets.all(tokens.spacing.xs), child: box),
      );
    }
    return MosaicPressFeedback(
      onPressed: enabled ? _toggle : null,
      enabled: enabled,
      semanticLabel: label,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: tokens.spacing.xs),
        child: Row(
          children: [
            box,
            SizedBox(width: tokens.spacing.sm),
            Expanded(
              child: Text(
                label!,
                style: tokens.typography.body.copyWith(
                  color: tokens.color.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.value, required this.enabled});

  final bool value;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    final fill = value ? tokens.color.accent : tokens.color.surface;
    final border = value
        ? tokens.color.accent
        : tokens.color.textSecondary;
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: fill,
        border: Border.all(color: border, width: 1.5),
        borderRadius: BorderRadius.circular(3),
      ),
      alignment: Alignment.center,
      child: value
          ? Text(
              '✓',
              style: TextStyle(
                color: tokens.color.textInverse,
                fontSize: 14,
                height: 1,
              ),
            )
          : null,
    );
  }
}
