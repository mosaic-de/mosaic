import 'package:flutter/widgets.dart';

import '../theme/mosaic_theme.dart';

/// Token-driven slider. Drag the thumb (or tap on the track) to set a
/// value between [min] and [max].
///
/// The slider is layout-aware — it derives the track width from the
/// constraints — so it adapts to any container.
class MosaicSlider extends StatefulWidget {
  const MosaicSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.enabled = true,
  }) : assert(min < max, 'min must be < max'),
       assert(divisions == null || divisions > 0, 'divisions must be > 0');

  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final int? divisions;
  final bool enabled;

  @override
  State<MosaicSlider> createState() => _MosaicSliderState();
}

class _MosaicSliderState extends State<MosaicSlider> {
  double _normalize(double v) {
    final clamped = v.clamp(widget.min, widget.max);
    if (widget.divisions == null) return clamped;
    final step = (widget.max - widget.min) / widget.divisions!;
    final ticks = ((clamped - widget.min) / step).round();
    return widget.min + ticks * step;
  }

  void _emitFromOffset(double localX, double trackWidth) {
    if (!widget.enabled || widget.onChanged == null) return;
    final ratio = (localX / trackWidth).clamp(0.0, 1.0);
    final raw = widget.min + ratio * (widget.max - widget.min);
    widget.onChanged!(_normalize(raw));
  }

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final clampedValue = widget.value.clamp(widget.min, widget.max);
        final ratio = (clampedValue - widget.min) / (widget.max - widget.min);
        return Opacity(
          opacity: widget.enabled ? 1 : 0.5,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) => _emitFromOffset(d.localPosition.dx, w),
            onHorizontalDragUpdate: (d) =>
                _emitFromOffset(d.localPosition.dx, w),
            child: SizedBox(
              height: 28,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Track — visible across both modes via alpha-tinted
                  // textSecondary (divider is too low-contrast).
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: tokens.color.textSecondary.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(tokens.radius.pill),
                    ),
                  ),
                  // Filled portion
                  FractionallySizedBox(
                    widthFactor: ratio,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: tokens.color.accent,
                        borderRadius: BorderRadius.circular(tokens.radius.pill),
                      ),
                    ),
                  ),
                  // Thumb
                  Positioned(
                    left: (w * ratio - 9).clamp(0.0, w - 18),
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: tokens.color.accent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: tokens.color.background,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
