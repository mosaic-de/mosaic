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
