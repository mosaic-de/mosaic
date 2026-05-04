import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

Widget _wrap(Widget child) {
  return MosaicApp(
    motionScale: 0,
    builder: (context) => Center(child: SizedBox(width: 320, child: child)),
  );
}

void main() {
  testWidgets('renders the currency code', (tester) async {
    await tester.pumpWidget(
      _wrap(
        MosaicCurrencyInput(cents: 12450, currency: 'USD', onChanged: (_) {}),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('USD'), findsOneWidget);
  });

  testWidgets('formats cents with the right decimal places', (tester) async {
    await tester.pumpWidget(
      _wrap(MosaicCurrencyInput(cents: 12450, onChanged: (_) {})),
    );
    await tester.pumpAndSettle();
    expect(find.text('124.50'), findsOneWidget);
  });

  testWidgets('typing emits a cents int', (tester) async {
    int? captured;
    await tester.pumpWidget(
      _wrap(MosaicCurrencyInput(cents: 0, onChanged: (v) => captured = v)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(MosaicCurrencyInput));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), '99.99');
    await tester.pumpAndSettle();
    expect(captured, 9999);
  });

  testWidgets('zero minor units formats as integer', (tester) async {
    await tester.pumpWidget(
      _wrap(MosaicCurrencyInput(cents: 1234, minorUnits: 0, onChanged: (_) {})),
    );
    await tester.pumpAndSettle();
    expect(find.text('1234'), findsOneWidget);
  });
}
