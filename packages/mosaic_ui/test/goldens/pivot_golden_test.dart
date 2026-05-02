@Tags(<String>['golden'])
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

import '_harness.dart';

Widget _body(MosaicTokens tokens, String label) {
  return Padding(
    padding: EdgeInsets.all(tokens.spacing.md),
    child: Text(
      label,
      style: tokens.typography.body.copyWith(color: tokens.color.textPrimary),
    ),
  );
}

void main() {
  testWidgets('pivot first active', (tester) async {
    await runGoldenMatrix(
      tester,
      name: 'pivot_active_first',
      size: const Size(480, 320),
      builder: (tokens) => SizedBox(
        width: 420,
        height: 240,
        child: MosaicPivot(
          pages: [
            MosaicPivotPage(
              label: 'Overview',
              child: _body(tokens, 'overview content'),
            ),
            MosaicPivotPage(
              label: 'Activity',
              child: _body(tokens, 'activity content'),
            ),
            MosaicPivotPage(
              label: 'Cards',
              child: _body(tokens, 'cards content'),
            ),
          ],
        ),
      ),
    );
  });

  testWidgets('pivot second active', (tester) async {
    await runGoldenMatrix(
      tester,
      name: 'pivot_active_second',
      size: const Size(480, 320),
      builder: (tokens) => SizedBox(
        width: 420,
        height: 240,
        child: MosaicPivot(
          initialIndex: 1,
          pages: [
            MosaicPivotPage(
              label: 'Overview',
              child: _body(tokens, 'overview content'),
            ),
            MosaicPivotPage(
              label: 'Activity',
              child: _body(tokens, 'activity content'),
            ),
            MosaicPivotPage(
              label: 'Cards',
              child: _body(tokens, 'cards content'),
            ),
          ],
        ),
      ),
    );
  });
}
