import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

void main() {
  group('resolveMosaicBrightness', () {
    test('system follows the device, both ways', () {
      expect(
        resolveMosaicBrightness(MosaicBrightnessChoice.system, Brightness.dark),
        Brightness.dark,
      );
      expect(
        resolveMosaicBrightness(
          MosaicBrightnessChoice.system,
          Brightness.light,
        ),
        Brightness.light,
      );
    });

    test('an explicit choice ignores the device outright', () {
      // The whole point of offering an override. One that quietly
      // deferred to the device at sunset would be worse than none.
      for (final platform in Brightness.values) {
        expect(
          resolveMosaicBrightness(MosaicBrightnessChoice.dark, platform),
          Brightness.dark,
        );
        expect(
          resolveMosaicBrightness(MosaicBrightnessChoice.light, platform),
          Brightness.light,
        );
      }
    });
  });

  group('mosaicSystemBarsFor', () {
    test('icons are always the inverse of the background', () {
      // Hardcoding either way is how the launcher painted white
      // status-bar icons onto its white light-mode background, hiding
      // the clock, battery and signal.
      final onDark = mosaicSystemBarsFor(Brightness.dark);
      expect(onDark.statusBarIconBrightness, Brightness.light);
      expect(onDark.systemNavigationBarIconBrightness, Brightness.light);

      final onLight = mosaicSystemBarsFor(Brightness.light);
      expect(onLight.statusBarIconBrightness, Brightness.dark);
      expect(onLight.systemNavigationBarIconBrightness, Brightness.dark);
    });

    test('iOS takes the background brightness, not the icons', () {
      // statusBarBrightness is inverted by iOS itself, so passing the
      // icon brightness there double-inverts and gets it backwards.
      expect(
        mosaicSystemBarsFor(Brightness.dark).statusBarBrightness,
        Brightness.dark,
      );
      expect(
        mosaicSystemBarsFor(Brightness.light).statusBarBrightness,
        Brightness.light,
      );
    });

    test('bars stay transparent so the token background shows through', () {
      for (final brightness in Brightness.values) {
        final style = mosaicSystemBarsFor(brightness);
        expect(style.statusBarColor?.a, 0);
        expect(style.systemNavigationBarColor?.a, 0);
        expect(style.systemNavigationBarContrastEnforced, isFalse);
      }
    });
  });

  group('fromName', () {
    test('round-trips every value', () {
      for (final choice in MosaicBrightnessChoice.values) {
        expect(MosaicBrightnessChoice.fromName(choice.name), choice);
      }
    });

    test('falls back to system on anything unrecognised', () {
      // Persisted preferences outlive the code that wrote them; an
      // unknown value must not throw on launch.
      for (final raw in <String?>[null, '', 'sepia', 'System']) {
        expect(
          MosaicBrightnessChoice.fromName(raw),
          MosaicBrightnessChoice.system,
        );
      }
    });
  });
}
