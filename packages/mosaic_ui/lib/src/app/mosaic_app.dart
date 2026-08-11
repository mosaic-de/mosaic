import 'package:flutter/widgets.dart';

import '../mode/mosaic_mode.dart';
import '../theme/mosaic_theme.dart';
import '../tokens/mosaic_tokens.dart';

/// Canonical entry point for a Mosaic application.
///
/// Owns the [MosaicMode] and [Brightness] state, builds the matching
/// [MosaicTokens], and installs them via [MosaicTheme]. Exposes the
/// mode/brightness handle to descendants through [MosaicAppScope].
///
/// Replaces the boilerplate of wiring `WidgetsApp + MosaicTheme +
/// per-screen mode juggling` by hand.
class MosaicApp extends StatefulWidget {
  const MosaicApp({
    super.key,
    required this.builder,
    this.title = '',
    this.initialMode = MosaicMode.metro,
    this.initialBrightness = Brightness.dark,
    this.motionScale = 1.0,
    this.onModeChanged,
    this.onBrightnessChanged,
    this.transparentBackground = false,
  });

  /// Called inside the [MosaicTheme] context. Build your top-level
  /// surface here — typically a [MosaicSurfaceHost] wrapping the home
  /// content.
  final WidgetBuilder builder;

  final String title;
  final MosaicMode initialMode;
  final Brightness initialBrightness;

  /// Global multiplier applied to every motion duration. Tests should
  /// pass `0` to make animations resolve immediately.
  final double motionScale;

  final ValueChanged<MosaicMode>? onModeChanged;
  final ValueChanged<Brightness>? onBrightnessChanged;

  /// When true, the app's background is rendered transparent so the
  /// host activity's window (typically a launcher with
  /// `windowShowWallpaper`) shows through. Defaults to false — most
  /// apps want the token background to fill the screen.
  final bool transparentBackground;

  @override
  State<MosaicApp> createState() => _MosaicAppState();
}

class _MosaicAppState extends State<MosaicApp> {
  late MosaicMode _mode = widget.initialMode;
  late Brightness _brightness = widget.initialBrightness;

  void _setMode(MosaicMode mode) {
    if (mode == _mode) return;
    setState(() => _mode = mode);
    widget.onModeChanged?.call(mode);
  }

  /// Binary metro ⇄ modern flip. Deliberately does *not* include aurora:
  /// this is the long-standing two-state toggle callers bind to a single
  /// button, and quietly turning it into a three-state cycle would change
  /// what that button does. Use [_cycleMode] to walk every mode.
  void _toggleMode() {
    _setMode(_mode == MosaicMode.metro ? MosaicMode.modern : MosaicMode.metro);
  }

  /// Advance to the next mode in declaration order, wrapping at the end.
  void _cycleMode() {
    const modes = MosaicMode.values;
    _setMode(modes[(modes.indexOf(_mode) + 1) % modes.length]);
  }

  void _setBrightness(Brightness brightness) {
    if (brightness == _brightness) return;
    setState(() => _brightness = brightness);
    widget.onBrightnessChanged?.call(brightness);
  }

  void _toggleBrightness() {
    _setBrightness(
      _brightness == Brightness.dark ? Brightness.light : Brightness.dark,
    );
  }

  MosaicTokens _resolveTokens(double effectiveScale) {
    return switch (_mode) {
      MosaicMode.metro => MosaicTokens.metro(
        brightness: _brightness,
        motionScale: effectiveScale,
      ),
      MosaicMode.modern => MosaicTokens.modern(
        brightness: _brightness,
        motionScale: effectiveScale,
      ),
      MosaicMode.aurora => MosaicTokens.aurora(
        brightness: _brightness,
        motionScale: effectiveScale,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    // Bootstrap tokens (with the configured motionScale) drive the
    // WidgetsApp's window color before MediaQuery is in scope. Inside
    // the home subtree we re-resolve with the actual reduced-motion-aware
    // scale and install that as the MosaicTheme. Using `home:` (not
    // `builder:`) is what triggers WidgetsApp to create a default
    // Navigator — without it, PopScope inside the surface stack has
    // nothing to attach to and Android's hardware back exits the app.
    final bootstrapTokens = _resolveTokens(widget.motionScale);
    return WidgetsApp(
      title: widget.title,
      color: widget.transparentBackground
          ? const Color(0x00000000)
          : bootstrapTokens.color.background,
      debugShowCheckedModeBanner: false,
      pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) =>
          PageRouteBuilder<T>(
            settings: settings,
            pageBuilder: (context, _, _) => builder(context),
          ),
      home: Builder(
        builder: (context) {
          final reduceMotion =
              MediaQuery.maybeDisableAnimationsOf(context) ?? false;
          final effectiveScale = reduceMotion ? 0.0 : widget.motionScale;
          final tokens = _resolveTokens(effectiveScale);
          return MosaicTheme(
            tokens: tokens,
            child: MosaicAppScope._(
              mode: _mode,
              brightness: _brightness,
              setMode: _setMode,
              toggleMode: _toggleMode,
              cycleMode: _cycleMode,
              setBrightness: _setBrightness,
              toggleBrightness: _toggleBrightness,
              child: widget.transparentBackground
                  ? Builder(builder: widget.builder)
                  : ColoredBox(
                      color: tokens.color.background,
                      child: Builder(builder: widget.builder),
                    ),
            ),
          );
        },
      ),
    );
  }
}

/// Inherited handle for reading and changing the active [MosaicMode] /
/// [Brightness] for the nearest [MosaicApp].
///
/// A toggle button in a command bar reads `mode` for its label and
/// calls `toggleMode()` on press — no callback plumbing required.
class MosaicAppScope extends InheritedWidget {
  const MosaicAppScope._({
    required this.mode,
    required this.brightness,
    required this.setMode,
    required this.toggleMode,
    required this.cycleMode,
    required this.setBrightness,
    required this.toggleBrightness,
    required super.child,
  });

  final MosaicMode mode;
  final Brightness brightness;
  final void Function(MosaicMode mode) setMode;

  /// Two-state metro ⇄ modern flip. Never selects aurora — see
  /// [cycleMode] for a control that walks every mode.
  final void Function() toggleMode;

  /// Advance through every [MosaicMode] in order, wrapping at the end.
  final void Function() cycleMode;
  final void Function(Brightness brightness) setBrightness;
  final void Function() toggleBrightness;

  static MosaicAppScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(
      scope != null,
      'No MosaicApp found in context. Wrap your top-level widget in a '
      'MosaicApp before calling MosaicAppScope.of.',
    );
    return scope!;
  }

  static MosaicAppScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MosaicAppScope>();
  }

  @override
  bool updateShouldNotify(MosaicAppScope oldWidget) =>
      mode != oldWidget.mode || brightness != oldWidget.brightness;
}
