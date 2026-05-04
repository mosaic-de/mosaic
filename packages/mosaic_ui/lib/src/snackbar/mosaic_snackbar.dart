import 'dart:async';

import 'package:flutter/widgets.dart';

import '../press/mosaic_press_feedback.dart';
import '../surface/mosaic_surface.dart';
import '../surface/mosaic_surface_kind.dart';
import '../theme/mosaic_theme.dart';
import '../tokens/mosaic_tokens.dart';

/// Severity of a snackbar message. Drives the accent color and the
/// glyph next to the label.
enum MosaicSnackbarTone { info, success, warning, error }

@immutable
class _SnackbarMessage {
  const _SnackbarMessage({
    required this.id,
    required this.label,
    required this.tone,
    required this.duration,
    this.actionLabel,
    this.onAction,
  });

  final int id;
  final String label;
  final MosaicSnackbarTone tone;
  final Duration duration;
  final String? actionLabel;
  final VoidCallback? onAction;
}

/// Inherited handle for showing transient messages. Wrap a surface in
/// [MosaicSnackbarHost] and call [show] from any descendant via
/// [MosaicSnackbarScope.of(context)].
class MosaicSnackbarScope {
  const MosaicSnackbarScope._(this._host);

  final _MosaicSnackbarHostState _host;

  static MosaicSnackbarScope of(BuildContext context) {
    final host = context
        .findAncestorStateOfType<_MosaicSnackbarHostState>();
    assert(host != null,
        'No MosaicSnackbarHost in context. Wrap your screen in one.');
    return MosaicSnackbarScope._(host!);
  }

  /// Show a message. The bar slides in, lingers for [duration], then
  /// dismisses. Returns immediately. Subsequent calls queue up.
  void show(
    String label, {
    MosaicSnackbarTone tone = MosaicSnackbarTone.info,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _host._enqueue(label,
        tone: tone,
        duration: duration,
        actionLabel: actionLabel,
        onAction: onAction);
  }

  void dismiss() => _host._dismissCurrent();
}

/// Hosts a transient snackbar overlay above its [child]. Place near the
/// root of your screen so messages float above tiles, panels, etc.
class MosaicSnackbarHost extends StatefulWidget {
  const MosaicSnackbarHost({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<MosaicSnackbarHost> createState() => _MosaicSnackbarHostState();
}

class _MosaicSnackbarHostState extends State<MosaicSnackbarHost> {
  final List<_SnackbarMessage> _queue = <_SnackbarMessage>[];
  Timer? _timer;
  int _nextId = 0;

  void _enqueue(
    String label, {
    required MosaicSnackbarTone tone,
    required Duration duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    setState(() {
      _queue.add(_SnackbarMessage(
        id: _nextId++,
        label: label,
        tone: tone,
        duration: duration,
        actionLabel: actionLabel,
        onAction: onAction,
      ));
    });
    if (_queue.length == 1) _arm();
  }

  void _arm() {
    _timer?.cancel();
    if (_queue.isEmpty) return;
    _timer = Timer(_queue.first.duration, _dismissCurrent);
  }

  void _dismissCurrent() {
    if (_queue.isEmpty) return;
    setState(() => _queue.removeAt(0));
    _arm();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    final current = _queue.isEmpty ? null : _queue.first;
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        Positioned(
          left: tokens.spacing.md,
          right: tokens.spacing.md,
          bottom: tokens.spacing.md,
          child: AnimatedSwitcher(
            duration: tokens.motion.scaledExpand,
            switchInCurve: tokens.motion.standardCurve,
            switchOutCurve: tokens.motion.standardCurve,
            transitionBuilder: (child, anim) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.4),
                end: Offset.zero,
              ).animate(anim),
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: current == null
                ? const SizedBox.shrink(key: ValueKey('snackbar.none'))
                : _SnackbarBody(
                    key: ValueKey('snackbar.${current.id}'),
                    message: current,
                    onDismiss: _dismissCurrent,
                  ),
          ),
        ),
      ],
    );
  }
}

class _SnackbarBody extends StatelessWidget {
  const _SnackbarBody({
    super.key,
    required this.message,
    required this.onDismiss,
  });

  final _SnackbarMessage message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    final accent = _toneColor(tokens, message.tone);
    return MosaicSurface(
      kind: MosaicSurfaceKind.panel,
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.md,
        vertical: tokens.spacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(width: 4, height: 24, color: accent),
          SizedBox(width: tokens.spacing.md),
          Expanded(
            child: Text(
              message.label,
              style: tokens.typography.body.copyWith(
                color: tokens.color.textPrimary,
              ),
            ),
          ),
          if (message.actionLabel != null && message.onAction != null) ...[
            SizedBox(width: tokens.spacing.sm),
            MosaicPressFeedback(
              onPressed: () {
                message.onAction!();
                onDismiss();
              },
              semanticLabel: message.actionLabel,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: tokens.spacing.sm,
                  vertical: tokens.spacing.xs,
                ),
                child: Text(
                  message.actionLabel!,
                  style: tokens.typography.tileTitle.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Color _toneColor(MosaicTokens tokens, MosaicSnackbarTone tone) => switch (tone) {
        MosaicSnackbarTone.info => tokens.color.accent,
        MosaicSnackbarTone.success => tokens.color.success,
        MosaicSnackbarTone.warning => tokens.color.warning,
        MosaicSnackbarTone.error => tokens.color.error,
      };
}
