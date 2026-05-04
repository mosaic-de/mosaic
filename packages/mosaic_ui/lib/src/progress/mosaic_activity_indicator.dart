import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/mosaic_theme.dart';

/// Indeterminate spinner. A single rotating ring with a 270° accent
/// arc — Metro-flavored: no Material spinner geometry, no shadow.
///
/// The animation honors `MediaQuery.disableAnimations` and the active
/// motion scale: when set to zero the widget renders a static frame so
/// goldens don't flake on tick boundaries.
class MosaicActivityIndicator extends StatefulWidget {
  const MosaicActivityIndicator({
    super.key,
    this.size = 24,
    this.strokeWidth = 2.5,
    this.color,
  });

  final double size;
  final double strokeWidth;
  final Color? color;

  @override
  State<MosaicActivityIndicator> createState() =>
      _MosaicActivityIndicatorState();
}

class _MosaicActivityIndicatorState extends State<MosaicActivityIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tokens = MosaicTheme.of(context);
    final disable = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final shouldRun = !disable && tokens.motion.scale > 0;
    if (shouldRun) {
      if (!_ctrl.isAnimating) _ctrl.repeat();
    } else {
      _ctrl.stop();
      _ctrl.value = 0;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    final color = widget.color ?? tokens.color.accent;
    final track = tokens.color.surfaceActive;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) => CustomPaint(
          painter: _RingPainter(
            angle: _ctrl.value * 2 * math.pi,
            color: color,
            track: track,
            stroke: widget.strokeWidth,
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.angle,
    required this.color,
    required this.track,
    required this.stroke,
  });

  final double angle;
  final Color color;
  final Color track;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final inset = Rect.fromLTRB(
      rect.left + stroke / 2,
      rect.top + stroke / 2,
      rect.right - stroke / 2,
      rect.bottom - stroke / 2,
    );
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = track;
    canvas.drawArc(inset, 0, 2 * math.pi, false, base);

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(inset, angle, math.pi * 1.5, false, arc);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.angle != angle ||
      old.color != color ||
      old.track != track ||
      old.stroke != stroke;
}
