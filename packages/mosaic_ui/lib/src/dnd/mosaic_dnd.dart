import 'package:flutter/widgets.dart';

import '../theme/mosaic_theme.dart';

/// Drag-and-drop primitives wrapped with token-driven feedback.
///
/// [MosaicDraggable] renders [child] as the draggable surface and the
/// same body as the floating drag avatar (subtly faded). [MosaicDropTarget]
/// reacts to a hovering payload by darkening its background and drawing
/// an accent border. Payload type [T] is whatever the producer publishes
/// (e.g. a `String` package id, an integer index, a domain object).
///
/// Both widgets are thin wrappers around Flutter's [Draggable] /
/// [DragTarget] — the value here is the consistent visual language
/// (token colors, motion-aware reveal) and the consistent ergonomics
/// (long-press by default; tap-and-drag if [longPress] is false).
class MosaicDraggable<T extends Object> extends StatelessWidget {
  const MosaicDraggable({
    super.key,
    required this.data,
    required this.child,
    this.feedback,
    this.childWhenDragging,
    this.onDragStarted,
    this.onDragCompleted,
    this.onDragCanceled,
    this.longPress = true,
    this.enabled = true,
  });

  final T data;
  final Widget child;

  /// Floating widget while the drag is in flight. Defaults to a faded
  /// copy of [child] so the user sees what they are moving.
  final Widget? feedback;

  /// Body shown in the source slot while the drag is in flight.
  /// Defaults to a placeholder square at 40% opacity.
  final Widget? childWhenDragging;

  final VoidCallback? onDragStarted;
  final VoidCallback? onDragCompleted;
  final VoidCallback? onDragCanceled;

  /// Long-press to start the drag. False switches to immediate (mouse
  /// or pointer) drag.
  final bool longPress;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    final fb = feedback ?? Opacity(opacity: 0.85, child: child);
    final placeholder = childWhenDragging ??
        Opacity(
          opacity: 0.4,
          child: IgnorePointer(child: child),
        );
    // When the drag gesture is disabled, render the child raw — the
    // host's own taps / long-presses on the tile must continue to
    // work. Wrapping in AbsorbPointer (or IgnorePointer) here would
    // dead-tile the whole grid.
    if (!enabled) return child;
    final draggable = longPress
        ? LongPressDraggable<T>(
            data: data,
            feedback: fb,
            childWhenDragging: placeholder,
            onDragStarted: onDragStarted,
            onDragCompleted: onDragCompleted,
            onDraggableCanceled: (_, __) => onDragCanceled?.call(),
            hapticFeedbackOnStart: true,
            child: child,
          )
        : Draggable<T>(
            data: data,
            feedback: fb,
            childWhenDragging: placeholder,
            onDragStarted: onDragStarted,
            onDragCompleted: onDragCompleted,
            onDraggableCanceled: (_, __) => onDragCanceled?.call(),
            child: child,
          );
    // Tokens wrap so motion + brightness propagate to the feedback
    // widget which Flutter renders in an Overlay.
    return MosaicTheme(tokens: tokens, child: draggable);
  }
}

/// Drop target. Calls [onAccept] when a [MosaicDraggable]&lt;T&gt; with a
/// matching payload type is released over [child].
///
/// The visual response is automatic: when a payload is hovering, the
/// target darkens and grows an accent dashed border. Use [highlight]
/// to disable this if you'd rather paint your own.
class MosaicDropTarget<T extends Object> extends StatelessWidget {
  const MosaicDropTarget({
    super.key,
    required this.onAccept,
    required this.child,
    this.canAccept,
    this.highlight = true,
  });

  final void Function(T data) onAccept;
  final bool Function(T data)? canAccept;
  final bool highlight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    return DragTarget<T>(
      onWillAcceptWithDetails: (details) =>
          canAccept?.call(details.data) ?? true,
      onAcceptWithDetails: (details) => onAccept(details.data),
      builder: (context, candidate, rejected) {
        final hovering = highlight && candidate.isNotEmpty;
        if (!hovering) return child;
        return DecoratedBox(
          decoration: BoxDecoration(
            color: tokens.color.accent.withValues(alpha: 0.08),
            border: Border.all(color: tokens.color.accent, width: 2),
            borderRadius: BorderRadius.circular(tokens.radius.tile.toDouble()),
          ),
          child: child,
        );
      },
    );
  }
}
