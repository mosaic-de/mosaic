@Tags(<String>['golden'])
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

import '_harness.dart';

void main() {
  testWidgets('icon set sample row', (tester) async {
    await runGoldenMatrix(
      tester,
      name: 'icon_row',
      size: const Size(420, 80),
      builder: (tokens) => const SizedBox(
        width: 360,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            MosaicIcon('search', size: 24),
            MosaicIcon('home', size: 24),
            MosaicIcon('settings', size: 24),
            MosaicIcon('star', size: 24),
            MosaicIcon('heart', size: 24),
            MosaicIcon('calendar', size: 24),
            MosaicIcon('clock', size: 24),
            MosaicIcon('refresh', size: 24),
          ],
        ),
      ),
    );
  });
}
