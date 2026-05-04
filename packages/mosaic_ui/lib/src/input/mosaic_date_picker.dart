import 'package:flutter/widgets.dart';

import '../calendar/mosaic_calendar.dart';
import '../press/mosaic_press_feedback.dart';
import '../surface/mosaic_panel.dart';
import '../surface/mosaic_surface.dart';
import '../surface/mosaic_surface_host.dart';
import '../surface/mosaic_surface_kind.dart';
import '../theme/mosaic_theme.dart';

/// Token-driven date input. Pressable surface that pushes a panel
/// containing a [MosaicCalendar] onto the surrounding
/// [MosaicSurfaceHost]'s stack.
///
/// Tapping a day fires [onChanged] and collapses the panel — no
/// separate Confirm button. If you want a confirm step, embed
/// [MosaicCalendar] directly in your own panel.
class MosaicDatePicker extends StatelessWidget {
  const MosaicDatePicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.placeholder = 'Pick a date',
    this.firstDay,
    this.lastDay,
    this.formatter,
    this.title = 'Date',
    this.enabled = true,
  });

  final DateTime? value;
  final ValueChanged<DateTime>? onChanged;
  final String placeholder;
  final DateTime? firstDay;
  final DateTime? lastDay;
  final String Function(DateTime date)? formatter;
  final String title;
  final bool enabled;

  String get _label {
    if (value == null) return placeholder;
    if (formatter != null) return formatter!(value!);
    return _defaultFormat(value!);
  }

  static String _defaultFormat(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd / $mm / ${d.year}';
  }

  void _open(BuildContext context) {
    final scope = MosaicSurfaceScope.of(context);
    scope.push(
      (panelContext) => _DatePanel(
        title: title,
        initial: value ?? DateTime.now(),
        firstDay: firstDay,
        lastDay: lastDay,
        onPicked: (date) {
          onChanged?.call(date);
          MosaicSurfaceScope.of(panelContext).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    final hasValue = value != null;
    return MosaicPressFeedback(
      onPressed: enabled ? () => _open(context) : null,
      enabled: enabled,
      semanticLabel: title,
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
                _label,
                style: tokens.typography.body.copyWith(
                  color: hasValue
                      ? tokens.color.textPrimary
                      : tokens.color.textSecondary.withValues(alpha: 0.7),
                ),
              ),
            ),
            SizedBox(width: tokens.spacing.sm),
            Text(
              '◫',
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

class _DatePanel extends StatelessWidget {
  const _DatePanel({
    required this.title,
    required this.initial,
    required this.onPicked,
    this.firstDay,
    this.lastDay,
  });

  final String title;
  final DateTime initial;
  final ValueChanged<DateTime> onPicked;
  final DateTime? firstDay;
  final DateTime? lastDay;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    final scope = MosaicSurfaceScope.of(context);
    return MosaicPanel(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.md,
        vertical: tokens.spacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                    textAlign: TextAlign.center,
                    style: tokens.typography.title.copyWith(
                      color: tokens.color.textPrimary,
                      height: 1,
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
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.md),
          Expanded(
            child: SingleChildScrollView(
              child: MosaicCalendar(
                selected: initial,
                firstDay: firstDay,
                lastDay: lastDay,
                onChanged: onPicked,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
