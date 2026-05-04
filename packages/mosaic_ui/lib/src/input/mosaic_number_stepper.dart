import 'package:flutter/widgets.dart';

import '../press/mosaic_press_feedback.dart';
import '../theme/mosaic_theme.dart';

/// Token-driven `−` / `+` integer stepper. Use it for quantities and
/// counts where typing a number is overkill — adding a guest, setting
/// a tip percentage, picking a number of cards.
///
/// Holding the buttons does not auto-repeat; consumers who need that
/// can wrap with their own gesture handler.
class MosaicNumberStepper extends StatelessWidget {
  const MosaicNumberStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max,
    this.step = 1,
    this.formatter,
    this.enabled = true,
  }) : assert(step > 0, 'step must be positive'),
       assert(max == null || max >= min, 'max must be >= min');

  final int value;
  final ValueChanged<int>? onChanged;
  final int min;
  final int? max;
  final int step;

  /// Optional formatter for the displayed number — useful for ranges
  /// that should read "$5" or "5 days".
  final String Function(int value)? formatter;

  final bool enabled;

  bool get _canDecrement => enabled && value - step >= min;
  bool get _canIncrement => enabled && (max == null || value + step <= max!);

  void _decrement() {
    if (!_canDecrement) return;
    onChanged?.call(value - step);
  }

  void _increment() {
    if (!_canIncrement) return;
    onChanged?.call(value + step);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    final display = formatter?.call(value) ?? value.toString();
    return Container(
      decoration: BoxDecoration(
        color: tokens.color.surface,
        borderRadius: BorderRadius.circular(tokens.radius.pill),
        border: Border.all(color: tokens.color.textPrimary, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            glyph: '−',
            onPressed: _decrement,
            enabled: _canDecrement,
            semanticLabel: 'Decrease',
          ),
          SizedBox(
            width: 56,
            child: Text(
              display,
              textAlign: TextAlign.center,
              style: tokens.typography.tileTitle.copyWith(
                color: tokens.color.textPrimary,
                fontWeight: FontWeight.w500,
                height: 1,
              ),
            ),
          ),
          _StepButton(
            glyph: '+',
            onPressed: _increment,
            enabled: _canIncrement,
            semanticLabel: 'Increase',
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.glyph,
    required this.onPressed,
    required this.enabled,
    required this.semanticLabel,
  });

  final String glyph;
  final VoidCallback onPressed;
  final bool enabled;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    return MosaicPressFeedback(
      onPressed: onPressed,
      enabled: enabled,
      semanticLabel: semanticLabel,
      child: SizedBox(
        width: 36,
        height: 36,
        child: Center(
          child: Text(
            glyph,
            style: tokens.typography.title.copyWith(
              color: tokens.color.textPrimary,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
