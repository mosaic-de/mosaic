@Tags(<String>['golden'])
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

import '_harness.dart';

Widget _carouselCard(MosaicTokens tokens, String label) {
  return MosaicSurface(
    kind: MosaicSurfaceKind.tile,
    color: tokens.color.accent,
    padding: EdgeInsets.all(tokens.spacing.lg),
    child: Center(
      child: Text(
        label,
        style: tokens.typography.title.copyWith(
          color: tokens.color.textInverse,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('carousel idle on page 0', (tester) async {
    await runGoldenMatrix(
      tester,
      name: 'carousel_page0',
      size: const Size(360, 220),
      builder: (tokens) => SizedBox(
        width: 320,
        child: MosaicCarousel(
          height: 140,
          items: [
            _carouselCard(tokens, 'A'),
            _carouselCard(tokens, 'B'),
            _carouselCard(tokens, 'C'),
          ],
        ),
      ),
    );
  });

  testWidgets('segmented row of three', (tester) async {
    await runGoldenMatrix(
      tester,
      name: 'segmented_row',
      size: const Size(360, 80),
      builder: (tokens) => MosaicSegmented<String>(
        value: 'b',
        onChanged: (_) {},
        segments: const [
          MosaicSegment(value: 'a', label: 'Day'),
          MosaicSegment(value: 'b', label: 'Week'),
          MosaicSegment(value: 'c', label: 'Month'),
        ],
      ),
    );
  });

  testWidgets('number stepper', (tester) async {
    await runGoldenMatrix(
      tester,
      name: 'number_stepper',
      size: const Size(280, 80),
      builder: (tokens) =>
          MosaicNumberStepper(value: 4, min: 1, max: 10, onChanged: (_) {}),
    );
  });
}
