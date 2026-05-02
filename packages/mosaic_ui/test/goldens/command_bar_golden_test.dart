@Tags(<String>['golden'])
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

import '_harness.dart';

void main() {
  testWidgets('command bar three commands', (tester) async {
    await runGoldenMatrix(
      tester,
      name: 'command_bar_three',
      size: const Size(420, 160),
      builder: (tokens) => SizedBox(
        width: 360,
        child: MosaicCommandBar(
          commands: [
            MosaicCommand(label: 'Search', glyph: '⌕', onPressed: () {}),
            MosaicCommand(label: 'Filter', glyph: '◇', onPressed: () {}),
            MosaicCommand(label: 'Export', glyph: '↗', onPressed: () {}),
          ],
        ),
      ),
    );
  });

  testWidgets('command bar with disabled', (tester) async {
    await runGoldenMatrix(
      tester,
      name: 'command_bar_disabled',
      size: const Size(420, 160),
      builder: (tokens) => SizedBox(
        width: 360,
        child: MosaicCommandBar(
          commands: [
            MosaicCommand(label: 'Save', glyph: '◇', onPressed: () {}),
            MosaicCommand(
              label: 'Delete',
              glyph: '×',
              enabled: false,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  });
}
