import 'package:flutter/widgets.dart';

import '../mode/mosaic_mode.dart';
import '../tokens/mosaic_tokens.dart';

/// Inherited widget that exposes [MosaicTokens] to descendants.
///
/// Components reach for tokens via [MosaicTheme.of] for required access
/// or [MosaicTheme.maybeOf] when running outside a Mosaic context.
class MosaicTheme extends InheritedWidget {
  const MosaicTheme({super.key, required this.tokens, required super.child});

  /// Convenience constructor for tests. Defaults to Metro/dark with motion
  /// scaled to zero so animations resolve immediately and goldens do not
  /// flake on timing.
  factory MosaicTheme.test({
    Key? key,
    MosaicMode mode = MosaicMode.metro,
    Brightness brightness = Brightness.dark,
    double motionScale = 0,
    required Widget child,
  }) {
    final tokens = switch (mode) {
      MosaicMode.metro => MosaicTokens.metro(
        brightness: brightness,
        motionScale: motionScale,
      ),
      MosaicMode.modern => MosaicTokens.modern(
        brightness: brightness,
        motionScale: motionScale,
      ),
    };
    return MosaicTheme(key: key, tokens: tokens, child: child);
  }

  final MosaicTokens tokens;

  /// Returns the nearest [MosaicTokens]. Throws if there is no
  /// [MosaicTheme] ancestor.
  static MosaicTokens of(BuildContext context) {
    final theme = maybeOf(context);
    assert(
      theme != null,
      'No MosaicTheme found in context. Wrap your app in a MosaicTheme '
      '(or MosaicApp) before using Mosaic components.',
    );
    return theme!;
  }

  /// Returns the nearest [MosaicTokens] or null if absent.
  static MosaicTokens? maybeOf(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<MosaicTheme>();
    return widget?.tokens;
  }

  @override
  bool updateShouldNotify(MosaicTheme oldWidget) => tokens != oldWidget.tokens;
}
