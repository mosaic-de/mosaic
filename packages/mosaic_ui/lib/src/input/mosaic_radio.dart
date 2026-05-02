import 'package:flutter/widgets.dart';

import '../press/mosaic_press_feedback.dart';
import '../theme/mosaic_theme.dart';

/// A single radio control. Use [MosaicRadioGroup] when picking one of
/// many — it wires the [groupValue]/[onChanged] plumbing for you.
class MosaicRadio<T> extends StatelessWidget {
  const MosaicRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.label,
    this.enabled = true,
  });

  final T value;
  final T? groupValue;
  final ValueChanged<T>? onChanged;
  final String? label;
  final bool enabled;

  bool get _selected => value == groupValue;

  void _select() => onChanged?.call(value);

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    final dot = _Dot(selected: _selected);
    if (label == null) {
      return MosaicPressFeedback(
        onPressed: enabled ? _select : null,
        enabled: enabled,
        semanticLabel: 'Radio',
        child: Padding(padding: EdgeInsets.all(tokens.spacing.xs), child: dot),
      );
    }
    return MosaicPressFeedback(
      onPressed: enabled ? _select : null,
      enabled: enabled,
      semanticLabel: label,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: tokens.spacing.xs),
        child: Row(
          children: [
            dot,
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

class _Dot extends StatelessWidget {
  const _Dot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    final outer = selected ? tokens.color.accent : tokens.color.divider;
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: outer, width: 1.5),
      ),
      alignment: Alignment.center,
      child: selected
          ? Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tokens.color.accent,
              ),
            )
          : null,
    );
  }
}

/// One option within a [MosaicRadioGroup].
@immutable
class MosaicRadioOption<T> {
  const MosaicRadioOption({required this.value, required this.label});
  final T value;
  final String label;
}

/// Vertical group of [MosaicRadio]s with shared [value] / [onChanged].
class MosaicRadioGroup<T> extends StatelessWidget {
  const MosaicRadioGroup({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.enabled = true,
  });

  final T? value;
  final List<MosaicRadioOption<T>> options;
  final ValueChanged<T>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final option in options)
          MosaicRadio<T>(
            value: option.value,
            groupValue: value,
            onChanged: onChanged,
            label: option.label,
            enabled: enabled,
          ),
      ],
    );
  }
}
