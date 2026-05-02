import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

Widget _wrap(Widget child) {
  return MosaicTheme.test(
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Center(child: child),
    ),
  );
}

void main() {
  testWidgets('selecting an option fires onChanged with that value', (
    tester,
  ) async {
    String? last;
    await tester.pumpWidget(
      _wrap(
        MosaicRadioGroup<String>(
          value: 'a',
          options: const [
            MosaicRadioOption(value: 'a', label: 'Alpha'),
            MosaicRadioOption(value: 'b', label: 'Beta'),
            MosaicRadioOption(value: 'c', label: 'Gamma'),
          ],
          onChanged: (v) => last = v,
        ),
      ),
    );
    await tester.tap(find.text('Beta'));
    await tester.pumpAndSettle();
    expect(last, 'b');
  });

  testWidgets('tapping the active option still reports it', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      _wrap(
        MosaicRadio<int>(
          value: 1,
          groupValue: 1,
          onChanged: (_) => calls++,
          label: 'One',
        ),
      ),
    );
    await tester.tap(find.text('One'));
    await tester.pumpAndSettle();
    expect(calls, 1);
  });

  testWidgets('disabled blocks tap', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      _wrap(
        MosaicRadio<int>(
          value: 1,
          groupValue: 0,
          enabled: false,
          onChanged: (_) => calls++,
          label: 'One',
        ),
      ),
    );
    await tester.tap(find.text('One'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(calls, 0);
  });
}
