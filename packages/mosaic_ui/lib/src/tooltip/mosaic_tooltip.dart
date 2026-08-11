import 'package:flutter/widgets.dart';

import '../theme/mosaic_theme.dart';

/// Token-styled tooltip. Wrap [child] and a long-press (or hover on
/// pointer devices) reveals [message] in a small inverse-toned bubble
/// above or below the anchor.
///
/// Differs from Flutter's stock Tooltip in that it picks up Mosaic
/// tokens (radius, surface colors, typography) and uses the design
/// system's motion tokens for the reveal.
class MosaicTooltip extends StatefulWidget {
  const MosaicTooltip({
    super.key,
    required this.message,
    required this.child,
    this.preferAbove = true,
    this.waitDuration = const Duration(milliseconds: 400),
    this.showDuration = const Duration(seconds: 2),
  });

  final String message;
  final Widget child;
  final bool preferAbove;
  final Duration waitDuration;
  final Duration showDuration;

  @override
  State<MosaicTooltip> createState() => _MosaicTooltipState();
}

class _MosaicTooltipState extends State<MosaicTooltip> {
  OverlayEntry? _entry;
  final LayerLink _link = LayerLink();

  void _toggle() {
    if (_entry != null) {
      _hide();
    } else {
      _show();
    }
  }

  void _show() {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;
    _entry = OverlayEntry(builder: _build);
    overlay.insert(_entry!);
    Future<void>.delayed(widget.showDuration, () {
      if (mounted) _hide();
    });
  }

  void _hide() {
    _entry?.remove();
    _entry = null;
  }

  Widget _build(BuildContext context) {
    final tokens = MosaicTheme.of(this.context);
    return Positioned.fill(
      child: IgnorePointer(
        child: CompositedTransformFollower(
          link: _link,
          showWhenUnlinked: false,
          offset: Offset(0, widget.preferAbove ? -36 : 36),
          child: Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.spacing.sm,
                vertical: tokens.spacing.xs,
              ),
              decoration: BoxDecoration(
                color: tokens.color.textPrimary,
                borderRadius: BorderRadius.circular(
                  tokens.radius.input.toDouble(),
                ),
              ),
              child: Text(
                widget.message,
                style: tokens.typography.caption.copyWith(
                  color: tokens.color.textInverse,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _hide();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPress: _toggle,
        child: MouseRegion(
          onEnter: (_) => _show(),
          onExit: (_) => _hide(),
          child: widget.child,
        ),
      ),
    );
  }
}
