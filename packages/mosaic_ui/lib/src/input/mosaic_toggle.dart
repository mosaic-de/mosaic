import 'package:flutter/widgets.dart';

import '../press/mosaic_press_feedback.dart';
import '../theme/mosaic_theme.dart';

/// Token-driven boolean switch. Use it for "on/off" settings —
/// "Frozen", "Notifications", "Dark mode", etc. For one-of-many use
/// [MosaicRadioGroup] instead.
class MosaicToggle extends StatelessWidget {
  const MosaicToggle({
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
    final track = _Track(value: value);
    if (label == null) {
      return MosaicPressFeedback(
        onPressed: enabled ? _toggle : null,
        enabled: enabled,
        semanticLabel: 'Toggle',
        child: Padding(
          padding: EdgeInsets.all(tokens.spacing.xs),
          child: track,
        ),
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
            Expanded(
              child: Text(
                label!,
                style: tokens.typography.body.copyWith(
                  color: tokens.color.textPrimary,
                ),
              ),
            ),
            SizedBox(width: tokens.spacing.md),
            track,
          ],
        ),
      ),
    );
  }
}

class _Track extends StatelessWidget {
  const _Track({required this.value});

  final bool value;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    final trackColor = value ? tokens.color.accent : tokens.color.surfaceMuted;
    final borderColor = value ? tokens.color.accent : tokens.color.divider;
    final thumbColor = value
        ? tokens.color.textInverse
        : tokens.color.textSecondary;
    return AnimatedContainer(
      duration: tokens.motion.scaledUpdate,
      curve: tokens.motion.standardCurve,
      width: 40,
      height: 22,
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(tokens.radius.pill),
        border: Border.all(color: borderColor, width: 1),
      ),
      alignment: value ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: thumbColor,
          borderRadius: BorderRadius.circular(tokens.radius.pill),
        ),
      ),
    );
  }
}
