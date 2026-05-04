import 'package:flutter/widgets.dart';

import '../press/mosaic_press_feedback.dart';
import '../segmented/mosaic_segmented.dart';
import '../surface/mosaic_panel.dart';
import '../surface/mosaic_surface.dart';
import '../surface/mosaic_surface_host.dart';
import '../surface/mosaic_surface_kind.dart';
import '../theme/mosaic_theme.dart';
import 'mosaic_number_stepper.dart';

/// Token-driven time-of-day input. Pressable surface that pushes a
/// panel containing two [MosaicNumberStepper]s (hour and minute) plus
/// an AM/PM [MosaicSegmented] when the picker is in 12-hour mode.
///
/// 24-hour mode hides the AM/PM segmented and accepts hours 0-23.
class MosaicTimePicker extends StatelessWidget {
  const MosaicTimePicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.placeholder = 'Pick a time',
    this.use24Hour = false,
    this.minuteStep = 1,
    this.title = 'Time',
    this.enabled = true,
  });

  final TimeOfDay? value;
  final ValueChanged<TimeOfDay>? onChanged;
  final String placeholder;
  final bool use24Hour;
  final int minuteStep;
  final String title;
  final bool enabled;

  String get _label {
    if (value == null) return placeholder;
    return _format(value!, use24Hour);
  }

  static String _format(TimeOfDay t, bool use24Hour) {
    final mm = t.minute.toString().padLeft(2, '0');
    if (use24Hour) {
      final hh = t.hour.toString().padLeft(2, '0');
      return '$hh:$mm';
    }
    final period = t.hour < 12 ? 'AM' : 'PM';
    final h12 = t.hour % 12 == 0 ? 12 : t.hour % 12;
    return '$h12:$mm $period';
  }

  void _open(BuildContext context) {
    final scope = MosaicSurfaceScope.of(context);
    scope.push(
      (panelContext) => _TimePanel(
        title: title,
        initial: value ?? const TimeOfDay(hour: 9, minute: 0),
        use24Hour: use24Hour,
        minuteStep: minuteStep,
        onPicked: (time) {
          onChanged?.call(time);
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
              '◷',
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

/// Like Flutter's [TimeOfDay] but defined locally so MosaicUI does not
/// depend on Material. Hour is 0-23, minute is 0-59.
@immutable
class TimeOfDay {
  const TimeOfDay({required this.hour, required this.minute})
    : assert(hour >= 0 && hour < 24, 'hour out of range'),
      assert(minute >= 0 && minute < 60, 'minute out of range');

  final int hour;
  final int minute;

  TimeOfDay copyWith({int? hour, int? minute}) =>
      TimeOfDay(hour: hour ?? this.hour, minute: minute ?? this.minute);

  @override
  bool operator ==(Object other) =>
      other is TimeOfDay && other.hour == hour && other.minute == minute;

  @override
  int get hashCode => Object.hash(hour, minute);

  @override
  String toString() => 'TimeOfDay($hour:$minute)';
}

class _TimePanel extends StatefulWidget {
  const _TimePanel({
    required this.title,
    required this.initial,
    required this.use24Hour,
    required this.minuteStep,
    required this.onPicked,
  });

  final String title;
  final TimeOfDay initial;
  final bool use24Hour;
  final int minuteStep;
  final ValueChanged<TimeOfDay> onPicked;

  @override
  State<_TimePanel> createState() => _TimePanelState();
}

enum _Period { am, pm }

class _TimePanelState extends State<_TimePanel> {
  late int _hour = widget.initial.hour;
  late int _minute = widget.initial.minute;

  _Period get _period => _hour < 12 ? _Period.am : _Period.pm;

  int get _displayHour {
    if (widget.use24Hour) return _hour;
    return _hour % 12 == 0 ? 12 : _hour % 12;
  }

  void _setHour(int displayHour) {
    setState(() {
      if (widget.use24Hour) {
        _hour = displayHour;
      } else {
        // displayHour is 1-12 in 12h mode
        final base = displayHour % 12;
        _hour = _period == _Period.am ? base : base + 12;
      }
    });
  }

  void _setMinute(int m) => setState(() => _minute = m);

  void _setPeriod(_Period p) {
    setState(() {
      if (p == _Period.am && _hour >= 12) _hour -= 12;
      if (p == _Period.pm && _hour < 12) _hour += 12;
    });
  }

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
                  widget.title,
                  style: tokens.typography.title.copyWith(
                    color: tokens.color.textPrimary,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Hour',
                    style: tokens.typography.caption.copyWith(
                      color: tokens.color.textSecondary,
                    ),
                  ),
                  SizedBox(height: tokens.spacing.xs),
                  MosaicNumberStepper(
                    value: _displayHour,
                    min: widget.use24Hour ? 0 : 1,
                    max: widget.use24Hour ? 23 : 12,
                    onChanged: _setHour,
                    formatter: (v) => v.toString().padLeft(2, '0'),
                  ),
                ],
              ),
              SizedBox(width: tokens.spacing.md),
              Padding(
                padding: EdgeInsets.only(top: tokens.spacing.lg),
                child: Text(
                  ':',
                  style: tokens.typography.headline.copyWith(
                    color: tokens.color.textPrimary,
                    height: 1,
                  ),
                ),
              ),
              SizedBox(width: tokens.spacing.md),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Minute',
                    style: tokens.typography.caption.copyWith(
                      color: tokens.color.textSecondary,
                    ),
                  ),
                  SizedBox(height: tokens.spacing.xs),
                  MosaicNumberStepper(
                    value: _minute,
                    min: 0,
                    max: 59,
                    step: widget.minuteStep,
                    onChanged: _setMinute,
                    formatter: (v) => v.toString().padLeft(2, '0'),
                  ),
                ],
              ),
            ],
          ),
          if (!widget.use24Hour) ...[
            SizedBox(height: tokens.spacing.lg),
            Center(
              child: MosaicSegmented<_Period>(
                value: _period,
                onChanged: _setPeriod,
                segments: const [
                  MosaicSegment(value: _Period.am, label: 'AM'),
                  MosaicSegment(value: _Period.pm, label: 'PM'),
                ],
              ),
            ),
          ],
          const Spacer(),
          Padding(
            padding: EdgeInsets.symmetric(vertical: tokens.spacing.md),
            child: MosaicPressFeedback(
              onPressed: () =>
                  widget.onPicked(TimeOfDay(hour: _hour, minute: _minute)),
              semanticLabel: 'Confirm time',
              child: Container(
                decoration: BoxDecoration(
                  color: tokens.color.accent,
                  borderRadius: BorderRadius.circular(tokens.radius.input),
                ),
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(
                  horizontal: tokens.spacing.md,
                  vertical: tokens.spacing.sm,
                ),
                child: Text(
                  'Confirm',
                  style: tokens.typography.tileTitle.copyWith(
                    color: tokens.color.textInverse,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
