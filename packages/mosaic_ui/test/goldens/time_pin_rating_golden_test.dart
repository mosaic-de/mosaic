@Tags(<String>['golden'])
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

import '_harness.dart';

void main() {
  testWidgets('time picker with value', (tester) async {
    await runGoldenMatrix(
      tester,
      name: 'time_picker_value',
      size: const Size(320, 80),
      builder: (tokens) => SizedBox(
        width: 240,
        child: MosaicTimePicker(
          value: const TimeOfDay(hour: 14, minute: 30),
          onChanged: (_) {},
        ),
      ),
    );
  });

  testWidgets('pin input partial', (tester) async {
    await runGoldenMatrix(
      tester,
      name: 'pin_input',
      size: const Size(360, 100),
      builder: (tokens) => SizedBox(
        width: 320,
        child: MosaicPinInput(length: 6, value: '123', onChanged: (_) {}),
      ),
    );
  });

  testWidgets('rating mid-value', (tester) async {
    await runGoldenMatrix(
      tester,
      name: 'rating',
      size: const Size(320, 60),
      builder: (tokens) => MosaicRating(value: 3, onChanged: (_) {}),
    );
  });
}
