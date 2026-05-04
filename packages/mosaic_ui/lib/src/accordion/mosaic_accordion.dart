import 'package:flutter/widgets.dart';

import '../press/mosaic_press_feedback.dart';
import '../theme/mosaic_theme.dart';

/// Single expand/collapse panel. Header stays visible; tapping it
/// flips the chevron and reveals/hides [child] with the system's
/// expand/collapse motion tokens.
///
/// The expanded state is internal by default. Pass [initiallyExpanded]
/// to seed it. For a controlled accordion (state owned by the parent),
/// build it from a [StatefulBuilder] that swaps [initiallyExpanded].
class MosaicAccordion extends StatefulWidget {
  const MosaicAccordion({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.initiallyExpanded = false,
    this.onChanged,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final bool initiallyExpanded;
  final ValueChanged<bool>? onChanged;

  @override
  State<MosaicAccordion> createState() => _MosaicAccordionState();
}

class _MosaicAccordionState extends State<MosaicAccordion> {
  late bool _expanded = widget.initiallyExpanded;

  void _toggle() {
    setState(() => _expanded = !_expanded);
    widget.onChanged?.call(_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MosaicPressFeedback(
          onPressed: _toggle,
          semanticLabel: widget.title,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.spacing.md,
              vertical: tokens.spacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: tokens.typography.tileTitle.copyWith(
                          color: tokens.color.textPrimary,
                        ),
                      ),
                      if (widget.subtitle != null) ...[
                        SizedBox(height: tokens.spacing.xs),
                        Text(
                          widget.subtitle!,
                          style: tokens.typography.caption.copyWith(
                            color: tokens.color.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: tokens.motion.scaledExpand,
                  curve: tokens.motion.standardCurve,
                  child: Text(
                    '⌄',
                    style: tokens.typography.title.copyWith(
                      color: tokens.color.textSecondary,
                      height: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          Padding(
            padding: EdgeInsets.fromLTRB(
              tokens.spacing.md,
              0,
              tokens.spacing.md,
              tokens.spacing.md,
            ),
            child: widget.child,
          ),
      ],
    );
  }
}
