@Tags(<String>['golden'])
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

import '_harness.dart';

void main() {
  testWidgets('range slider mid-range', (tester) async {
    await runGoldenMatrix(
      tester,
      name: 'range_slider',
      size: const Size(320, 80),
      builder: (tokens) => SizedBox(
        width: 240,
        child: MosaicRangeSlider(start: 0.25, end: 0.75, onChanged: (_, _) {}),
      ),
    );
  });

  testWidgets('tag input with three tags', (tester) async {
    await runGoldenMatrix(
      tester,
      name: 'tag_input',
      size: const Size(360, 80),
      builder: (tokens) => SizedBox(
        width: 320,
        child: MosaicTagInput(
          tags: const ['flutter', 'design', 'metro'],
          onChanged: (_) {},
        ),
      ),
    );
  });

  testWidgets('currency input with value', (tester) async {
    await runGoldenMatrix(
      tester,
      name: 'currency_input',
      size: const Size(320, 80),
      builder: (tokens) => SizedBox(
        width: 280,
        child: MosaicCurrencyInput(
          cents: 12450,
          currency: 'KES',
          onChanged: (_) {},
        ),
      ),
    );
  });
}
