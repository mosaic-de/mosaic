@Tags(<String>['golden'])
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

import '_harness.dart';

void main() {
  testWidgets('input idle and search', (tester) async {
    await runGoldenMatrix(
      tester,
      name: 'input_idle',
      size: const Size(360, 200),
      builder: (tokens) => SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const MosaicInput(placeholder: 'Recipient'),
            SizedBox(height: tokens.spacing.sm),
            const MosaicSearchInput(),
          ],
        ),
      ),
    );
  });

  testWidgets('chip row mixed selection', (tester) async {
    await runGoldenMatrix(
      tester,
      name: 'chip_row',
      size: const Size(360, 120),
      builder: (tokens) => SizedBox(
        width: 320,
        child: Wrap(
          spacing: tokens.spacing.sm,
          runSpacing: tokens.spacing.xs,
          children: [
            MosaicChip(label: 'All', selected: true, onPressed: () {}),
            MosaicChip(label: 'Income', selected: false, onPressed: () {}),
            MosaicChip(label: 'Expenses', selected: false, onPressed: () {}),
          ],
        ),
      ),
    );
  });
}
