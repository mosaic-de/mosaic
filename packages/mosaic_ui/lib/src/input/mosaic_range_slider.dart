import 'package:flutter/widgets.dart';

import '../theme/mosaic_theme.dart';

/// Two-thumb slider for ranges (price filter, age filter, time window).
/// Drag either thumb; the closer-to-touch thumb wins. Thumbs can meet
/// but not cross.
class MosaicRangeSlider extends StatefulWidget {
  const MosaicRangeSlider({
    super.key,
    required this.start,
    required this.end,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.enabled = true,
  }) : assert(min < max, 'min must be < max'),
       assert(divisions == null || divisions > 0, 'divisions must be > 0'),
       assert(start <= end, 'start must be <= end');

  final double start;
  final double end;
  final void Function(double start, double end)? onChanged;
  final double min;
  final double max;
  final int? divisions;
  final bool enabled;

  @override
  State<MosaicRangeSlider> createState() => _MosaicRangeSliderState();
}

class _MosaicRangeSliderState extends State<MosaicRangeSlider> {
  bool _draggingStart = true;

  double _normalize(double v) {
    final clamped = v.clamp(widget.min, widget.max);
    if (widget.divisions == null) return clamped;
    final step = (widget.max - widget.min) / widget.divisions!;
    final ticks = ((clamped - widget.min) / step).round();
    return widget.min + ticks * step;
  }

  void _emit(double localX, double width) {
    if (!widget.enabled || widget.onChanged == null) return;
    final ratio = (localX / width).clamp(0.0, 1.0);
    final value = _normalize(widget.min + ratio * (widget.max - widget.min));
    if (_draggingStart) {
      widget.onChanged!(value.clamp(widget.min, widget.end), widget.end);
    } else {
      widget.onChanged!(widget.start, value.clamp(widget.start, widget.max));
    }
  }

  void _decideThumb(double localX, double width) {
    final ratio = (localX / width).clamp(0.0, 1.0);
    final value = widget.min + ratio * (widget.max - widget.min);
    final distStart = (value - widget.start).abs();
    final distEnd = (value - widget.end).abs();
    _draggingStart = distStart <= distEnd;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    final span = widget.max - widget.min;
    final startRatio = (widget.start - widget.min) / span;
    final endRatio = (widget.end - widget.min) / span;
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        return Opacity(
          opacity: widget.enabled ? 1 : 0.5,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanDown: (d) => _decideThumb(d.localPosition.dx, w),
            onTapDown: (d) {
              _decideThumb(d.localPosition.dx, w);
              _emit(d.localPosition.dx, w);
            },
            onHorizontalDragUpdate: (d) => _emit(d.localPosition.dx, w),
            child: SizedBox(
              height: 28,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Full track
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: tokens.color.textSecondary,
                      borderRadius: BorderRadius.circular(tokens.radius.pill),
                    ),
                  ),
                  // Active region between thumbs
                  Positioned(
                    left: w * startRatio,
                    width: w * (endRatio - startRatio),
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: tokens.color.accent,
                        borderRadius: BorderRadius.circular(tokens.radius.pill),
                      ),
                    ),
                  ),
                  // Start thumb
                  Positioned(
                    left: (w * startRatio - 9).clamp(0.0, w - 18),
                    child: _Thumb(),
                  ),
                  // End thumb
                  Positioned(
                    left: (w * endRatio - 9).clamp(0.0, w - 18),
                    child: _Thumb(),
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

class _Thumb extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: tokens.color.accent,
        shape: BoxShape.circle,
        border: Border.all(color: tokens.color.background, width: 2),
      ),
    );
  }
}
