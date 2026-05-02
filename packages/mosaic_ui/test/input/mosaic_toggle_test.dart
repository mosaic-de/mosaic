import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

Widget _wrap(Widget child) {
  return MosaicTheme.test(
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Center(child: SizedBox(width: 240, child: child)),
    ),
  );
}

void main() {
  testWidgets('tapping the row flips the value', (tester) async {
    bool? captured;
    await tester.pumpWidget(
      _wrap(
        MosaicToggle(
          value: false,
          label: 'Frozen',
          onChanged: (v) => captured = v,
        ),
      ),
    );
    await tester.tap(find.text('Frozen'));
    await tester.pumpAndSettle();
    expect(captured, isTrue);
  });

  testWidgets('disabled blocks toggle', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      _wrap(
        MosaicToggle(
          value: false,
          enabled: false,
          label: 'Frozen',
          onChanged: (_) => calls++,
        ),
      ),
    );
    await tester.tap(find.text('Frozen'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(calls, 0);
  });

  testWidgets('renders label when present', (tester) async {
    await tester.pumpWidget(
      _wrap(MosaicToggle(value: true, label: 'Alerts', onChanged: (_) {})),
    );
    expect(find.text('Alerts'), findsOneWidget);
  });
}
