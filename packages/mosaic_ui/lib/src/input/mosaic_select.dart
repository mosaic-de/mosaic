import 'package:flutter/widgets.dart';

import '../list/mosaic_list.dart';
import '../press/mosaic_press_feedback.dart';
import '../surface/mosaic_panel.dart';
import '../surface/mosaic_surface.dart';
import '../surface/mosaic_surface_host.dart';
import '../surface/mosaic_surface_kind.dart';
import '../theme/mosaic_theme.dart';

/// One option within a [MosaicSelect].
@immutable
class MosaicSelectOption<T> {
  const MosaicSelectOption({required this.value, required this.label});
  final T value;
  final String label;
}

/// Token-driven dropdown. When tapped, pushes a selection panel onto
/// the surrounding [MosaicSurfaceHost]'s stack — picking an option
/// fires [onChanged] and collapses the panel.
///
/// Requires a [MosaicSurfaceHost] ancestor so the picker has somewhere
/// to push its panel.
class MosaicSelect<T> extends StatelessWidget {
  const MosaicSelect({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.placeholder,
    this.title = 'Select',
    this.enabled = true,
  });

  final T? value;
  final List<MosaicSelectOption<T>> options;
  final ValueChanged<T>? onChanged;
  final String? placeholder;
  final String title;
  final bool enabled;

  String? get _currentLabel {
    if (value == null) return null;
    for (final option in options) {
      if (option.value == value) return option.label;
    }
    return null;
  }

  void _open(BuildContext context) {
    final scope = MosaicSurfaceScope.of(context);
    scope.push(
      (panelContext) => _SelectPanel<T>(
        title: title,
        currentValue: value,
        options: options,
        onPicked: (picked) {
          onChanged?.call(picked);
          MosaicSurfaceScope.of(panelContext).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    final label = _currentLabel ?? placeholder ?? '';
    final hasValue = _currentLabel != null;
    return MosaicPressFeedback(
      onPressed: enabled ? () => _open(context) : null,
      enabled: enabled,
      semanticLabel: hasValue ? label : (placeholder ?? title),
      child: Container(
        decoration: BoxDecoration(
          color: tokens.color.surface,
          borderRadius: BorderRadius.circular(tokens.radius.input),
          border: Border.all(color: tokens.color.divider, width: 1),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spacing.md,
          vertical: tokens.spacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: tokens.typography.body.copyWith(
                  color: hasValue
                      ? tokens.color.textPrimary
                      : tokens.color.textSecondary.withValues(alpha: 0.7),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: tokens.spacing.sm),
            Text(
              '⌄',
              style: tokens.typography.body.copyWith(
                color: tokens.color.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectPanel<T> extends StatelessWidget {
  const _SelectPanel({
    required this.title,
    required this.currentValue,
    required this.options,
    required this.onPicked,
  });

  final String title;
  final T? currentValue;
  final List<MosaicSelectOption<T>> options;
  final ValueChanged<T> onPicked;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    final scope = MosaicSurfaceScope.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.md,
        vertical: tokens.spacing.md,
      ),
      child: MosaicPanel(
        padding: EdgeInsets.all(tokens.spacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                MosaicPressFeedback(
                  onPressed: scope.pop,
                  semanticLabel: 'Cancel',
                  child: MosaicSurface(
                    kind: MosaicSurfaceKind.muted,
                    padding: EdgeInsets.symmetric(
                      horizontal: tokens.spacing.sm,
                      vertical: tokens.spacing.xs,
                    ),
                    child: Text(
                      '←',
                      style: tokens.typography.title.copyWith(
                        color: tokens.color.textPrimary,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: tokens.spacing.md),
                Expanded(
                  child: Text(
                    title,
                    style: tokens.typography.title.copyWith(
                      color: tokens.color.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.spacing.md),
            Flexible(
              child: MosaicList(
                shrinkWrap: true,
                rows: [
                  for (final option in options)
                    MosaicListRow(
                      title: option.label,
                      trailing: option.value == currentValue
                          ? Text(
                              '✓',
                              style: tokens.typography.body.copyWith(
                                color: tokens.color.accent,
                              ),
                            )
                          : null,
                      onPressed: () => onPicked(option.value),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
