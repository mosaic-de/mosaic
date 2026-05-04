@Tags(<String>['golden'])
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

import '_harness.dart';

void main() {
  testWidgets('calendar with selection', (tester) async {
    await runGoldenMatrix(
      tester,
      name: 'calendar',
      size: const Size(360, 380),
      builder: (tokens) => SizedBox(
        width: 320,
        child: MosaicCalendar(
          selected: DateTime(2026, 5, 15),
          initialMonth: DateTime(2026, 5),
          onChanged: (_) {},
        ),
      ),
    );
  });

  testWidgets('date picker with value', (tester) async {
    await runGoldenMatrix(
      tester,
      name: 'date_picker_value',
      size: const Size(320, 80),
      builder: (tokens) => SizedBox(
        width: 240,
        child: MosaicDatePicker(
          value: DateTime(2026, 5, 15),
          onChanged: (_) {},
        ),
      ),
    );
  });

  testWidgets('date picker placeholder', (tester) async {
    await runGoldenMatrix(
      tester,
      name: 'date_picker_placeholder',
      size: const Size(320, 80),
      builder: (tokens) => SizedBox(
        width: 240,
        child: MosaicDatePicker(
          value: null,
          onChanged: (_) {},
          placeholder: 'Pick a date',
        ),
      ),
    );
  });
}
