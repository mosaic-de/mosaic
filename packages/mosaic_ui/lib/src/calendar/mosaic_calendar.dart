import 'package:flutter/widgets.dart';

import '../press/mosaic_press_feedback.dart';
import '../theme/mosaic_theme.dart';

/// Standalone month grid. Embed it inline inside a calendar surface, or
/// host it inside a [MosaicDatePicker]'s pushed panel.
///
/// Tap a day to select it. The selected day paints the accent fill;
/// today is outlined; days outside the visible month are dimmed.
class MosaicCalendar extends StatefulWidget {
  const MosaicCalendar({
    super.key,
    required this.selected,
    required this.onChanged,
    this.firstDay,
    this.lastDay,
    this.initialMonth,
    this.startOfWeek = DateTime.monday,
  }) : assert(
         startOfWeek == DateTime.monday || startOfWeek == DateTime.sunday,
         'startOfWeek must be DateTime.monday or DateTime.sunday',
       );

  final DateTime selected;
  final ValueChanged<DateTime> onChanged;
  final DateTime? firstDay;
  final DateTime? lastDay;
  final DateTime? initialMonth;
  final int startOfWeek;

  @override
  State<MosaicCalendar> createState() => _MosaicCalendarState();
}

class _MosaicCalendarState extends State<MosaicCalendar> {
  late DateTime _visible = _firstOfMonth(
    widget.initialMonth ?? widget.selected,
  );

  static DateTime _firstOfMonth(DateTime d) => DateTime(d.year, d.month);

  static const _monthNames = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const _weekdayNamesMonFirst = <String>[
    'M',
    'T',
    'W',
    'T',
    'F',
    'S',
    'S',
  ];
  static const _weekdayNamesSunFirst = <String>[
    'S',
    'M',
    'T',
    'W',
    'T',
    'F',
    'S',
  ];

  void _previousMonth() {
    setState(() => _visible = DateTime(_visible.year, _visible.month - 1));
  }

  void _nextMonth() {
    setState(() => _visible = DateTime(_visible.year, _visible.month + 1));
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _enabled(DateTime day) {
    if (widget.firstDay != null && day.isBefore(widget.firstDay!)) return false;
    if (widget.lastDay != null && day.isAfter(widget.lastDay!)) return false;
    return true;
  }

  List<DateTime?> _gridCells() {
    final firstWeekday = _visible.weekday;
    final leading = (firstWeekday - widget.startOfWeek + 7) % 7;
    final daysInMonth = DateTime(_visible.year, _visible.month + 1, 0).day;
    final cells = <DateTime?>[];
    for (var i = 0; i < leading; i++) {
      cells.add(null);
    }
    for (var d = 1; d <= daysInMonth; d++) {
      cells.add(DateTime(_visible.year, _visible.month, d));
    }
    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    return cells;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    final cells = _gridCells();
    final weekdayNames = widget.startOfWeek == DateTime.monday
        ? _weekdayNamesMonFirst
        : _weekdayNamesSunFirst;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(
          label: '${_monthNames[_visible.month - 1]} ${_visible.year}',
          onPrevious: _previousMonth,
          onNext: _nextMonth,
        ),
        SizedBox(height: tokens.spacing.sm),
        Row(
          children: [
            for (final name in weekdayNames)
              Expanded(
                child: Center(
                  child: Text(
                    name,
                    style: tokens.typography.caption.copyWith(
                      color: tokens.color.textSecondary,
                    ),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: tokens.spacing.xs),
        for (var row = 0; row < cells.length / 7; row++)
          Row(
            children: [
              for (var col = 0; col < 7; col++)
                Expanded(
                  child: _DayCell(
                    day: cells[row * 7 + col],
                    selected: cells[row * 7 + col] != null
                        ? _isSameDay(cells[row * 7 + col]!, widget.selected)
                        : false,
                    today: cells[row * 7 + col] != null
                        ? _isSameDay(cells[row * 7 + col]!, DateTime.now())
                        : false,
                    enabled: cells[row * 7 + col] != null
                        ? _enabled(cells[row * 7 + col]!)
                        : false,
                    onPressed: cells[row * 7 + col] != null
                        ? () => widget.onChanged(cells[row * 7 + col]!)
                        : null,
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.label,
    required this.onPrevious,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    return Row(
      children: [
        _ArrowButton(
          glyph: '‹',
          onPressed: onPrevious,
          semantic: 'Previous month',
        ),
        Expanded(
          child: Center(
            child: Text(
              label,
              style: tokens.typography.title.copyWith(
                color: tokens.color.textPrimary,
                height: 1,
              ),
            ),
          ),
        ),
        _ArrowButton(glyph: '›', onPressed: onNext, semantic: 'Next month'),
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.glyph,
    required this.onPressed,
    required this.semantic,
  });

  final String glyph;
  final VoidCallback onPressed;
  final String semantic;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    return MosaicPressFeedback(
      onPressed: onPressed,
      semanticLabel: semantic,
      child: SizedBox(
        width: 32,
        height: 32,
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

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.selected,
    required this.today,
    required this.enabled,
    required this.onPressed,
  });

  final DateTime? day;
  final bool selected;
  final bool today;
  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    if (day == null) {
      return const AspectRatio(aspectRatio: 1, child: SizedBox.shrink());
    }
    final fg = selected
        ? tokens.color.textInverse
        : enabled
        ? tokens.color.textPrimary
        : tokens.color.textSecondary.withValues(alpha: 0.4);
    final bg = selected ? tokens.color.accent : const Color(0x00000000);
    final border = today && !selected
        ? Border.all(color: tokens.color.accent, width: 1.5)
        : null;
    return MosaicPressFeedback(
      onPressed: enabled ? onPressed : null,
      enabled: enabled,
      semanticLabel: 'Day ${day!.day}',
      child: AspectRatio(
        aspectRatio: 1,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Container(
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              border: border,
            ),
            alignment: Alignment.center,
            child: Text(
              '${day!.day}',
              style: tokens.typography.body.copyWith(
                color: fg,
                fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
