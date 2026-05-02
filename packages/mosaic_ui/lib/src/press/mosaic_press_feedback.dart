import 'package:flutter/widgets.dart';

import '../state/interaction_state.dart';
import '../theme/mosaic_theme.dart';
import '../tokens/mosaic_tokens.dart';

/// Adds press, hover, focus, and disabled feedback to any child.
///
/// Visual feedback is mode-aware:
///   * Metro: background dim only on press (no scale).
///   * Modern: background dim + 0.98 scale on press.
///
/// All durations come from [MosaicMotionTokens]; widget tests using
/// `MosaicTheme.test` get instant transitions.
class MosaicPressFeedback extends StatefulWidget {
  const MosaicPressFeedback({
    super.key,
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.enabled = true,
    this.semanticLabel,
    this.semanticHint,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final bool enabled;
  final String? semanticLabel;
  final String? semanticHint;

  bool get isInteractive =>
      enabled && (onPressed != null || onLongPress != null);

  @override
  State<MosaicPressFeedback> createState() => _MosaicPressFeedbackState();
}

class _MosaicPressFeedbackState extends State<MosaicPressFeedback> {
  bool _pressed = false;
  bool _hovered = false;
  bool _focused = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  void _setHovered(bool value) {
    if (_hovered == value) return;
    setState(() => _hovered = value);
  }

  void _setFocused(bool value) {
    if (_focused == value) return;
    setState(() => _focused = value);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    final state = InteractionState(
      pressed: _pressed && widget.isInteractive,
      hovered: _hovered && widget.isInteractive,
      focused: _focused && widget.enabled,
      disabled: !widget.enabled,
    );

    final overlay = _overlayColor(tokens, state) ?? const Color(0x00000000);
    final focusBorder = state.focused
        ? tokens.color.accent
        : const Color(0x00000000);
    final scale = _pressScale(tokens, state);
    final opacity = state.disabled ? 0.45 : 1.0;

    // The wrapper tree is intentionally stable across interaction states:
    // the overlay and focus border layers are always present, just with
    // transparent paint when idle. Adding/removing wrappers based on
    // press state would remount descendants and flicker. The decoration
    // updates are not animated — Mosaic press feedback is instant by
    // design; only the optional Modern scale animates.
    Widget content = Container(
      foregroundDecoration: BoxDecoration(color: overlay),
      decoration: BoxDecoration(
        border: Border.all(color: focusBorder, width: 2),
        borderRadius: BorderRadius.circular(tokens.radius.tile),
      ),
      child: widget.child,
    );

    content = AnimatedScale(
      scale: scale,
      duration: tokens.motion.scaledPress,
      curve: tokens.motion.standardCurve,
      child: AnimatedOpacity(
        opacity: opacity,
        duration: tokens.motion.scaledUpdate,
        curve: tokens.motion.standardCurve,
        child: content,
      ),
    );

    if (widget.isInteractive) {
      content = MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => _setHovered(true),
        onExit: (_) => _setHovered(false),
        child: Focus(
          canRequestFocus: widget.enabled,
          onFocusChange: _setFocused,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) => _setPressed(true),
            onTapUp: (_) => _setPressed(false),
            onTapCancel: () => _setPressed(false),
            onTap: widget.onPressed,
            onLongPress: widget.onLongPress,
            child: content,
          ),
        ),
      );
    }

    return Semantics(
      label: widget.semanticLabel,
      hint: widget.semanticHint,
      button: widget.isInteractive,
      enabled: widget.enabled,
      child: content,
    );
  }

  Color? _overlayColor(MosaicTokens tokens, InteractionState s) {
    final base = tokens.color.textPrimary;
    if (s.pressed) {
      return base.withValues(alpha: tokens.isMetro ? 0.10 : 0.06);
    }
    if (s.hovered) {
      return base.withValues(alpha: 0.04);
    }
    return null;
  }

  double _pressScale(MosaicTokens tokens, InteractionState s) {
    if (!s.pressed) return 1.0;
    return tokens.isModern ? 0.98 : 1.0;
  }
}
