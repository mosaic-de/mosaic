import 'package:flutter/widgets.dart';

import '../theme/mosaic_theme.dart';

/// Inherited handle for pushing/popping layers on the surface stack
/// owned by the nearest [MosaicSurfaceHost].
///
/// `Surface → expand → act → collapse` replaces `Home → Page → Page`.
/// Most navigation in a Mosaic app should go through this, not
/// `Navigator.push`.
class MosaicSurfaceScope extends InheritedWidget {
  const MosaicSurfaceScope._({
    required this.depth,
    required this.push,
    required this.pop,
    required super.child,
  });

  /// 0 means the base body is showing. >0 means at least one layer is
  /// expanded.
  final int depth;

  /// Push a layer onto the stack. The [builder] is called inside the
  /// host's coordinate space and should typically return a
  /// [MosaicPanel].
  final void Function(WidgetBuilder builder) push;

  /// Collapse the topmost layer. No-op when [depth] is 0.
  final void Function() pop;

  static MosaicSurfaceScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(
      scope != null,
      'No MosaicSurfaceHost found in context. Wrap your screen in a '
      'MosaicSurfaceHost before calling MosaicSurfaceScope.of.',
    );
    return scope!;
  }

  static MosaicSurfaceScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MosaicSurfaceScope>();
  }

  @override
  bool updateShouldNotify(MosaicSurfaceScope oldWidget) =>
      depth != oldWidget.depth;
}

/// Owns the expansion stack for a Mosaic screen. Wrap your top-level
/// surface body in this; descendants reach for the stack via
/// [MosaicSurfaceScope.of].
///
/// Back navigation:
///   * stack non-empty → pop the top layer (collapse animation).
///   * stack empty → propagate to the enclosing route.
class MosaicSurfaceHost extends StatefulWidget {
  const MosaicSurfaceHost({super.key, required this.body});

  final Widget body;

  @override
  State<MosaicSurfaceHost> createState() => _MosaicSurfaceHostState();
}

class _MosaicSurfaceHostState extends State<MosaicSurfaceHost>
    with TickerProviderStateMixin {
  final List<_LayerEntry> _stack = <_LayerEntry>[];

  void _push(WidgetBuilder builder) {
    final tokens = MosaicTheme.of(context);
    final controller = AnimationController(
      vsync: this,
      duration: tokens.motion.scaledExpand,
      reverseDuration: tokens.motion.scaledCollapse,
    );
    final entry = _LayerEntry(builder: builder, controller: controller);
    setState(() => _stack.add(entry));
    controller.forward();
  }

  void _pop() {
    if (_stack.isEmpty) return;
    final top = _stack.last;
    top.controller.reverse().whenCompleteOrCancel(() {
      if (mounted) {
        setState(() => _stack.remove(top));
      } else {
        _stack.remove(top);
      }
      top.controller.dispose();
    });
  }

  @override
  void dispose() {
    for (final entry in _stack) {
      entry.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    return MosaicSurfaceScope._(
      depth: _stack.length,
      push: _push,
      pop: _pop,
      child: PopScope(
        canPop: _stack.isEmpty,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _pop();
        },
        child: Stack(
          alignment: Alignment.topLeft,
          fit: StackFit.expand,
          children: [
            widget.body,
            for (final entry in _stack)
              _LayerView(
                key: ValueKey<_LayerEntry>(entry),
                animation: entry.controller,
                curve: tokens.motion.standardCurve,
                child: Builder(builder: entry.builder),
              ),
          ],
        ),
      ),
    );
  }
}

class _LayerEntry {
  _LayerEntry({required this.builder, required this.controller});
  final WidgetBuilder builder;
  final AnimationController controller;
}

class _LayerView extends StatelessWidget {
  const _LayerView({
    super.key,
    required this.animation,
    required this.curve,
    required this.child,
  });

  final Animation<double> animation;
  final Curve curve;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: animation, curve: curve);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
