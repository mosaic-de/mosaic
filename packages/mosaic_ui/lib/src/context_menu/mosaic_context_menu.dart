import 'package:flutter/widgets.dart';

import '../press/mosaic_press_feedback.dart';
import '../surface/mosaic_panel.dart';
import '../theme/mosaic_theme.dart';
import '../tokens/mosaic_tokens.dart';

/// One row in a context menu.
@immutable
class MosaicContextAction {
  const MosaicContextAction({
    required this.label,
    required this.onPressed,
    this.glyph,
    this.destructive = false,
  });

  final String label;
  final VoidCallback onPressed;

  /// Optional leading single-character glyph.
  final String? glyph;

  /// When true, the row is rendered with the error color so dangerous
  /// actions (Delete, Uninstall) read at a glance.
  final bool destructive;
}

/// Wrap a child so a long-press anchors a small popover menu of
/// [actions] right above (or below) it. A single tap pass-through to
/// [onPressed] if supplied; otherwise the child remains inert until
/// long-pressed.
///
/// Designed for tile and list-row affordances. For full-screen
/// confirmations reach for the surface stack instead.
class MosaicContextMenu extends StatefulWidget {
  const MosaicContextMenu({
    super.key,
    required this.actions,
    required this.child,
    this.onPressed,
    this.preferAbove = true,
  });

  final List<MosaicContextAction> actions;
  final Widget child;
  final VoidCallback? onPressed;
  final bool preferAbove;

  @override
  State<MosaicContextMenu> createState() => _MosaicContextMenuState();
}

class _MosaicContextMenuState extends State<MosaicContextMenu> {
  OverlayEntry? _entry;

  void _open() {
    if (_entry != null) return;
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final size = renderBox.size;
    final origin = renderBox.localToGlobal(Offset.zero);

    _entry = OverlayEntry(
      builder: (overlayContext) => _MenuOverlay(
        anchorRect: Rect.fromLTWH(
          origin.dx,
          origin.dy,
          size.width,
          size.height,
        ),
        actions: widget.actions,
        preferAbove: widget.preferAbove,
        onClose: _close,
        tokens: MosaicTheme.of(context),
      ),
    );
    overlay.insert(_entry!);
  }

  void _close() {
    _entry?.remove();
    _entry = null;
  }

  @override
  void dispose() {
    _close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onPressed,
      onLongPress: _open,
      child: widget.child,
    );
  }
}

class _MenuOverlay extends StatelessWidget {
  const _MenuOverlay({
    required this.anchorRect,
    required this.actions,
    required this.preferAbove,
    required this.onClose,
    required this.tokens,
  });

  final Rect anchorRect;
  final List<MosaicContextAction> actions;
  final bool preferAbove;
  final VoidCallback onClose;

  /// Tokens captured at the call site, where a [MosaicTheme] is in
  /// scope. Typed, not `dynamic` — the previous `dynamic` is what let
  /// this field sit unused without the compiler minding.
  final MosaicTokens tokens;

  @override
  Widget build(BuildContext context) {
    // Reinstall the captured theme over the whole overlay subtree.
    //
    // This build runs inside the Overlay's context, and the Overlay is
    // created by WidgetsApp *above* the point where MosaicApp installs
    // MosaicTheme (inside `home:`). So there is no MosaicTheme ancestor
    // here: this widget read `MosaicTheme.of(context)` and asserted,
    // and so did every Mosaic component beneath it — MosaicPanel,
    // MosaicPressFeedback, MosaicText. Passing `tokens` down by hand
    // would fix this widget and leave all of those still broken, so the
    // theme goes back into the tree instead and they all resolve.
    final t = tokens;
    final approxHeight = actions.length * 44.0 + t.spacing.sm * 2;
    final left = anchorRect.left;
    final top = preferAbove
        ? (anchorRect.top - approxHeight - t.spacing.sm)
        : (anchorRect.bottom + t.spacing.sm);
    return MosaicTheme(
      tokens: t,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onClose,
              child: ColoredBox(
                color: const Color(
                  0xFF000000,
                ).withValues(alpha: t.effect.scrimOpacity),
              ),
            ),
          ),
          Positioned(
            left: left,
            top: top.clamp(0.0, double.infinity),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 240),
              child: MosaicPanel(
                padding: EdgeInsets.symmetric(vertical: t.spacing.xs),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final action in actions)
                      _ActionRow(action: action, onAfter: onClose),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.action, required this.onAfter});

  final MosaicContextAction action;
  final VoidCallback onAfter;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    final color = action.destructive
        ? tokens.color.error
        : tokens.color.textPrimary;
    return MosaicPressFeedback(
      onPressed: () {
        action.onPressed();
        onAfter();
      },
      semanticLabel: action.label,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spacing.md,
          vertical: tokens.spacing.sm,
        ),
        child: Row(
          children: [
            if (action.glyph != null) ...[
              Text(
                action.glyph!,
                style: tokens.typography.body.copyWith(color: color, height: 1),
              ),
              SizedBox(width: tokens.spacing.sm),
            ],
            Expanded(
              child: Text(
                action.label,
                style: tokens.typography.body.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
