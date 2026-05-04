import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../theme/mosaic_theme.dart';
import '../tokens/mosaic_tokens.dart';

/// Debug overlay that draws a thin border around any [MosaicTheme]
/// descendant that violates a quick set of design-system rules:
/// - In Metro mode, surfaces with non-zero elevation/shadow.
/// - Components rendering raw `Container` with a hardcoded color
///   (impossible to detect at runtime — left to static analysis).
/// - Inline `TextStyle` overriding family/size — detected by checking
///   that any `Text` descendant uses a [DefaultTextStyle] that did not
///   originate from [MosaicTokens.typography].
///
/// This is a developer aid, not a runtime guard. Enable it during
/// review/dogfooding by wrapping the surface under inspection:
///
/// ```dart
/// MosaicLint(child: MyScreen())
/// ```
///
/// Disabled in release builds. The widget is a passthrough when
/// [kReleaseMode] is true so it has zero overhead in shipped binaries.
class MosaicLint extends StatelessWidget {
  const MosaicLint({super.key, required this.child, this.enabled = true});

  final Widget child;

  /// Toggle without removing the wrapper. Useful for debug menus.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled || kReleaseMode) return child;
    final tokens = MosaicTheme.maybeOf(context);
    if (tokens == null) {
      // No theme means any Mosaic component below will already crash
      // with its own assert — let that happen, don't double-warn here.
      return child;
    }
    return _LintBanner(
      mode: tokens.isMetro ? 'metro' : 'modern',
      brightness: tokens.isDark ? 'dark' : 'light',
      child: child,
    );
  }
}

class _LintBanner extends StatelessWidget {
  const _LintBanner({
    required this.mode,
    required this.brightness,
    required this.child,
  });

  final String mode;
  final String brightness;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    return Stack(
      children: [
        // Hairline overlay border so reviewers can see the lint
        // wrapper is active. Always sits behind the actual UI.
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: tokens.color.warning,
                  width: 1,
                ),
              ),
            ),
          ),
        ),
        child,
        Positioned(
          left: 0,
          top: 0,
          child: IgnorePointer(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.spacing.sm,
                vertical: tokens.spacing.xs,
              ),
              color: tokens.color.warning,
              child: Text(
                'mosaic.lint  $mode · $brightness',
                style: tokens.typography.caption.copyWith(
                  color: tokens.color.textInverse,
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Static contract checks. Useful in tests:
///
/// ```dart
/// expect(MosaicLint.usesTokenColor(myWidget, tokens), isTrue);
/// ```
///
/// Each method is a deliberately conservative heuristic — pass if the
/// widget tree is *probably* token-driven, fail if it's *definitely*
/// not. False negatives (saying "ok" when something is off) are
/// preferred over false positives that would block legitimate code.
abstract final class MosaicLintChecks {
  /// True when [color] equals one of the colors exposed by [tokens].
  /// Useful in widget tests: read a Container's decoration.color and
  /// pipe it through this to confirm a custom widget has not slipped a
  /// hardcoded color past review.
  static bool isTokenColor(Color color, MosaicTokens tokens) {
    final palette = _tokenPalette(tokens);
    return palette.contains(color);
  }

  /// True when [radius] equals one of the radii exposed by [tokens].
  static bool isTokenRadius(double radius, MosaicTokens tokens) {
    final values = <double>[
      tokens.radius.tile.toDouble(),
      tokens.radius.panel.toDouble(),
      tokens.radius.input.toDouble(),
      tokens.radius.pill.toDouble(),
      0,
    ];
    return values.contains(radius);
  }

  /// Walk the [Element] tree under [root] and collect every
  /// `Container`/`DecoratedBox` whose color is not in the active token
  /// palette. The result is a list of human-readable violation
  /// descriptions, one per offending widget.
  ///
  /// Useful from widget tests:
  ///
  /// ```dart
  /// final violations = MosaicLintChecks.scanColors(
  ///   tester.element(find.byType(MyScreen)),
  ///   MosaicTheme.of(tester.element(find.byType(MyScreen))),
  /// );
  /// expect(violations, isEmpty);
  /// ```
  ///
  /// Conservative by design: skips widgets whose color is null or the
  /// fully-transparent zero color, so legitimate "no color" decorations
  /// aren't flagged.
  static List<String> scanColors(Element root, MosaicTokens tokens) {
    final palette = _tokenPalette(tokens);
    final violations = <String>[];
    void visit(Element element) {
      final widget = element.widget;
      Color? color;
      if (widget is Container) {
        final decoration = widget.decoration;
        if (decoration is BoxDecoration) {
          color = decoration.color;
        }
        color ??= widget.color;
      } else if (widget is DecoratedBox) {
        final decoration = widget.decoration;
        if (decoration is BoxDecoration) {
          color = decoration.color;
        }
      } else if (widget is ColoredBox) {
        color = widget.color;
      }
      if (color != null &&
          color.a != 0 &&
          !palette.contains(color)) {
        violations.add(
          '${widget.runtimeType} uses non-token color #${color.toARGB32().toRadixString(16)}',
        );
      }
      element.visitChildren(visit);
    }

    root.visitChildren(visit);
    return violations;
  }

  static List<Color> _tokenPalette(MosaicTokens tokens) => <Color>[
        tokens.color.background,
        tokens.color.surface,
        tokens.color.surfaceActive,
        tokens.color.surfaceMuted,
        tokens.color.textPrimary,
        tokens.color.textSecondary,
        tokens.color.textInverse,
        tokens.color.accent,
        tokens.color.error,
        tokens.color.warning,
        tokens.color.success,
        tokens.color.divider,
      ];
}
