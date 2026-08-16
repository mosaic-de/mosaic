import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

void main() {
  group('MosaicTokens.metro', () {
    test('produces zero elevation in every slot', () {
      final tokens = MosaicTokens.metro();
      expect(tokens.elevation.tile, 0);
      expect(tokens.elevation.panel, 0);
      expect(tokens.elevation.overlay, 0);
    });

    test('uses sharp tile radius (<=6)', () {
      final tokens = MosaicTokens.metro();
      expect(tokens.radius.tile, lessThanOrEqualTo(6));
    });

    test('reports isMetro and respects brightness flag', () {
      final dark = MosaicTokens.metro();
      final light = MosaicTokens.metro(brightness: Brightness.light);
      expect(dark.isMetro, isTrue);
      expect(dark.isDark, isTrue);
      expect(light.isLight, isTrue);
      expect(dark.color.background, isNot(light.color.background));
    });

    test('motion press is snappy (<=120ms)', () {
      final tokens = MosaicTokens.metro();
      expect(tokens.motion.press.inMilliseconds, lessThanOrEqualTo(120));
    });
  });

  group('MosaicTokens.modern', () {
    test('uses softer tile radius (>=10)', () {
      final tokens = MosaicTokens.modern();
      expect(tokens.radius.tile, greaterThanOrEqualTo(10));
    });

    test('introduces subtle elevation but stays minimal', () {
      final tokens = MosaicTokens.modern();
      expect(tokens.elevation.tile, greaterThan(0));
      expect(tokens.elevation.tile, lessThanOrEqualTo(4));
    });

    test('reports isModern', () {
      expect(MosaicTokens.modern().isModern, isTrue);
    });
  });

  group('MosaicTokens.aurora', () {
    test('reports isAurora and not the other modes', () {
      final tokens = MosaicTokens.aurora();
      expect(tokens.isAurora, isTrue);
      expect(tokens.isMetro, isFalse);
      expect(tokens.isModern, isFalse);
      expect(tokens.modeName, 'aurora');
    });

    test('uses large radii, well past modern', () {
      expect(
        MosaicTokens.aurora().radius.tile,
        greaterThan(MosaicTokens.modern().radius.tile),
      );
      expect(MosaicTokens.aurora().radius.panel, greaterThanOrEqualTo(24));
    });

    test('is the only default mode that renders as glass', () {
      expect(MosaicTokens.aurora().effect.isGlass, isTrue);
      expect(MosaicTokens.metro().effect.isGlass, isFalse);
      expect(MosaicTokens.modern().effect.isGlass, isFalse);
    });

    test('asks for translucency, blur, and a hairline edge', () {
      final effect = MosaicTokens.aurora().effect;
      expect(effect.surfaceOpacity, lessThan(1));
      expect(effect.surfaceBlur, greaterThan(0));
      expect(effect.overlayBlur, greaterThan(effect.surfaceBlur));
      expect(effect.strokeWidth, greaterThan(0));
      expect(effect.strokeOpacity, greaterThan(0));
    });

    test('restores saturation and lights the top edge', () {
      // The two that separate real glass from grey fog. Blur averages
      // neighbouring pixels and drains colour, so saturation must be
      // pushed back *above* parity; and a pane with no lit edge reads
      // as a tinted hole rather than an object.
      final effect = MosaicTokens.aurora().effect;
      expect(effect.saturation, greaterThan(1.0));
      expect(effect.sheenOpacity, greaterThan(0));
    });

    test('blur is heavy enough to read as frosted, not smudged', () {
      expect(
        MosaicTokens.aurora().effect.surfaceBlur,
        greaterThanOrEqualTo(24),
      );
    });

    test('the pane is mostly backdrop, not mostly tint', () {
      final effect = MosaicTokens.aurora().effect;
      expect(effect.surfaceOpacity, lessThan(0.65));
    });

    test('light glass takes a stronger sheen than dark', () {
      // Inverse of the stroke rule: a white sheen barely registers on a
      // light surface, while on dark it would blow out.
      final dark = MosaicTokens.aurora().effect;
      final light = MosaicTokens.aurora(brightness: Brightness.light).effect;
      expect(light.sheenOpacity, greaterThan(dark.sheenOpacity));
    });

    test('leaves structure alone — spacing and columns match metro', () {
      final aurora = MosaicTokens.aurora();
      final metro = MosaicTokens.metro();
      expect(aurora.spacing, metro.spacing);
      expect(aurora.grid.columnsMobile, metro.grid.columnsMobile);
      expect(aurora.grid.columnsTablet, metro.grid.columnsTablet);
      expect(aurora.grid.columnsDesktop, metro.grid.columnsDesktop);
    });

    test('motion decelerates longer than metro', () {
      expect(
        MosaicTokens.aurora().motion.expand.inMilliseconds,
        greaterThan(MosaicTokens.metro().motion.expand.inMilliseconds),
      );
    });

    test('dark and light differ in palette and edge strength', () {
      final dark = MosaicTokens.aurora();
      final light = MosaicTokens.aurora(brightness: Brightness.light);
      expect(dark.color.background, isNot(light.color.background));
      expect(
        dark.effect.strokeOpacity,
        greaterThan(light.effect.strokeOpacity),
      );
    });
  });

  group('MosaicEffectTokens', () {
    test('defaults to the opaque metro answer', () {
      const effect = MosaicEffectTokens();
      expect(effect.isGlass, isFalse);
      expect(effect.surfaceOpacity, 1.0);
      expect(effect.surfaceBlur, 0);
      expect(effect.strokeWidth, 0);
    });

    test('copyWith preserves untouched fields', () {
      const base = MosaicEffectTokens(surfaceBlur: 10, strokeWidth: 2);
      final copy = base.copyWith(surfaceBlur: 20);
      expect(copy.surfaceBlur, 20);
      expect(copy.strokeWidth, 2);
    });
  });

  group('motion scaling', () {
    test('motionScale 0 collapses durations to zero', () {
      final tokens = MosaicTokens.metro(motionScale: 0);
      expect(tokens.motion.scaledPress, Duration.zero);
      expect(tokens.motion.scaledExpand, Duration.zero);
      expect(tokens.motion.scaledPivot, Duration.zero);
    });

    test('motionScale 0.5 halves durations', () {
      final tokens = MosaicTokens.metro(motionScale: 0.5);
      expect(
        tokens.motion.scaledExpand.inMicroseconds,
        (tokens.motion.expand.inMicroseconds * 0.5).round(),
      );
    });

    test('motionScale 1.0 leaves durations untouched', () {
      final tokens = MosaicTokens.metro();
      expect(tokens.motion.scaledPress, tokens.motion.press);
    });
  });

  group('equality', () {
    test('two metro instances with same brightness are equal', () {
      expect(MosaicTokens.metro(), MosaicTokens.metro());
    });

    test('metro and modern are not equal', () {
      expect(MosaicTokens.metro(), isNot(MosaicTokens.modern()));
    });

    test('copyWith preserves untouched fields', () {
      final base = MosaicTokens.metro();
      final copy = base.copyWith(brightness: Brightness.light);
      expect(copy.spacing, base.spacing);
      expect(copy.brightness, Brightness.light);
    });
  });
}
