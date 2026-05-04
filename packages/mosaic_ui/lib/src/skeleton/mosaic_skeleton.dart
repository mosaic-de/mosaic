import 'package:flutter/widgets.dart';

import '../theme/mosaic_theme.dart';

/// Content-shaped loading placeholder with a soft pulse. Use as the
/// body of a tile or row while the real value is loading; better than
/// a generic spinner because the user sees the *layout* arrive before
/// the data fills in.
///
/// The pulse honors [MediaQuery.disableAnimations] and the active
/// motion scale: when set to zero the widget renders the muted base
/// color statically so goldens don't flake on tick boundaries.
class MosaicSkeleton extends StatefulWidget {
  const MosaicSkeleton({
    super.key,
    this.width,
    this.height,
    this.radius,
  });

  /// Convenience: a single-line text-shaped skeleton.
  const MosaicSkeleton.line({
    super.key,
    this.width,
    this.height = 14,
    this.radius = 4,
  });

  /// Convenience: a square avatar-shaped skeleton.
  const MosaicSkeleton.avatar({
    super.key,
    double size = 36,
    this.radius,
  })  : width = size,
        height = size;

  final double? width;
  final double? height;
  final double? radius;

  @override
  State<MosaicSkeleton> createState() => _MosaicSkeletonState();
}

class _MosaicSkeletonState extends State<MosaicSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tokens = MosaicTheme.of(context);
    final disable = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final shouldRun = !disable && tokens.motion.scale > 0;
    if (shouldRun) {
      if (!_ctrl.isAnimating) _ctrl.repeat(reverse: true);
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
    final radius = widget.radius ?? tokens.radius.tile.toDouble();
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final t = _ctrl.value;
          // Lerp between two muted surface tones for a subtle pulse.
          final color = Color.lerp(
            tokens.color.surfaceMuted,
            tokens.color.surfaceActive,
            t,
          )!;
          return DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(radius),
            ),
          );
        },
      ),
    );
  }
}
