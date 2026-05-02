import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

/// Fixed token-set matrix every component golden runs against.
///
/// Four entries: `metro/dark`, `metro/light`, `modern/dark`,
/// `modern/light`. Adding a fifth (e.g. high-contrast) goes here so
/// every component picks it up.
const goldenMatrix = <(MosaicMode, Brightness)>[
  (MosaicMode.metro, Brightness.dark),
  (MosaicMode.metro, Brightness.light),
  (MosaicMode.modern, Brightness.dark),
  (MosaicMode.modern, Brightness.light),
];

const _goldenRootKey = ValueKey<String>('mosaic.golden.root');

/// Run `builder` against every entry in [goldenMatrix] and write a
/// golden PNG for each. Each output filename is
/// `goldens/<name>.<mode>.<brightness>.png`.
///
/// Tag tests with the `golden` tag so CI can exclude them on hosts that
/// did not generate the snapshots.
Future<void> runGoldenMatrix(
  WidgetTester tester, {
  required String name,
  required Widget Function(MosaicTokens tokens) builder,
  Size size = const Size(360, 240),
}) async {
  for (final (mode, brightness) in goldenMatrix) {
    final tokens = mode == MosaicMode.metro
        ? MosaicTokens.metro(brightness: brightness, motionScale: 0)
        : MosaicTokens.modern(brightness: brightness, motionScale: 0);

    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(size: size),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: MosaicTheme(
            tokens: tokens,
            child: RepaintBoundary(
              key: _goldenRootKey,
              child: ColoredBox(
                color: tokens.color.background,
                child: SizedBox.expand(child: Center(child: builder(tokens))),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(_goldenRootKey),
      matchesGoldenFile('$name.${mode.name}.${brightness.name}.png'),
    );
  }
}
