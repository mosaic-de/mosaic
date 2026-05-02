@Tags(<String>['golden'])
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

import '_harness.dart';

void main() {
  testWidgets('checkbox states', (tester) async {
    await runGoldenMatrix(
      tester,
      name: 'checkbox',
      size: const Size(320, 200),
      builder: (tokens) => SizedBox(
        width: 280,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MosaicCheckbox(value: true, onChanged: (_) {}, label: 'Subscribe'),
            MosaicCheckbox(
              value: false,
              onChanged: (_) {},
              label: 'Notifications',
            ),
            MosaicCheckbox(
              value: true,
              enabled: false,
              onChanged: (_) {},
              label: 'Disabled',
            ),
          ],
        ),
      ),
    );
  });

  testWidgets('radio group', (tester) async {
    await runGoldenMatrix(
      tester,
      name: 'radio_group',
      size: const Size(320, 200),
      builder: (tokens) => SizedBox(
        width: 280,
        child: MosaicRadioGroup<String>(
          value: 'metro',
          onChanged: (_) {},
          options: const [
            MosaicRadioOption(value: 'metro', label: 'Metro'),
            MosaicRadioOption(value: 'modern', label: 'Modern'),
            MosaicRadioOption(value: 'custom', label: 'Custom'),
          ],
        ),
      ),
    );
  });

  testWidgets('toggle states', (tester) async {
    await runGoldenMatrix(
      tester,
      name: 'toggle',
      size: const Size(320, 200),
      builder: (tokens) => SizedBox(
        width: 280,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MosaicToggle(
              value: true,
              onChanged: (_) {},
              label: 'Notifications',
            ),
            MosaicToggle(value: false, onChanged: (_) {}, label: 'Frozen'),
            MosaicToggle(
              value: true,
              enabled: false,
              onChanged: (_) {},
              label: 'Disabled',
            ),
          ],
        ),
      ),
    );
  });

  testWidgets('slider mid-range', (tester) async {
    await runGoldenMatrix(
      tester,
      name: 'slider',
      size: const Size(320, 80),
      builder: (tokens) => SizedBox(
        width: 240,
        child: MosaicSlider(value: 0.6, onChanged: (_) {}),
      ),
    );
  });

  testWidgets('select with chosen value', (tester) async {
    await runGoldenMatrix(
      tester,
      name: 'select_chosen',
      size: const Size(320, 120),
      builder: (tokens) => SizedBox(
        width: 240,
        child: MosaicSelect<String>(
          value: 'metro',
          options: const [
            MosaicSelectOption(value: 'metro', label: 'Metro'),
            MosaicSelectOption(value: 'modern', label: 'Modern'),
          ],
          onChanged: (_) {},
        ),
      ),
    );
  });

  testWidgets('select empty placeholder', (tester) async {
    await runGoldenMatrix(
      tester,
      name: 'select_placeholder',
      size: const Size(320, 120),
      builder: (tokens) => SizedBox(
        width: 240,
        child: MosaicSelect<String>(
          value: null,
          options: const [
            MosaicSelectOption(value: 'metro', label: 'Metro'),
            MosaicSelectOption(value: 'modern', label: 'Modern'),
          ],
          onChanged: (_) {},
          placeholder: 'Pick a mode',
        ),
      ),
    );
  });
}
