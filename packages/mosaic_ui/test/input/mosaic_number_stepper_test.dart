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
  testWidgets('renders the value', (tester) async {
    await tester.pumpWidget(
      _wrap(MosaicNumberStepper(value: 5, onChanged: (_) {})),
    );
    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('+ increments', (tester) async {
    int? next;
    await tester.pumpWidget(
      _wrap(MosaicNumberStepper(value: 5, onChanged: (v) => next = v)),
    );
    await tester.tap(find.text('+'));
    await tester.pumpAndSettle();
    expect(next, 6);
  });

  testWidgets('− decrements', (tester) async {
    int? next;
    await tester.pumpWidget(
      _wrap(MosaicNumberStepper(value: 5, onChanged: (v) => next = v)),
    );
    await tester.tap(find.text('−'));
    await tester.pumpAndSettle();
    expect(next, 4);
  });

  testWidgets('respects min', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      _wrap(MosaicNumberStepper(value: 0, min: 0, onChanged: (_) => calls++)),
    );
    await tester.tap(find.text('−'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(calls, 0);
  });

  testWidgets('respects max', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      _wrap(MosaicNumberStepper(value: 10, max: 10, onChanged: (_) => calls++)),
    );
    await tester.tap(find.text('+'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(calls, 0);
  });

  testWidgets('formatter customizes the display', (tester) async {
    await tester.pumpWidget(
      _wrap(
        MosaicNumberStepper(
          value: 5,
          onChanged: (_) {},
          formatter: (v) => '$v days',
        ),
      ),
    );
    expect(find.text('5 days'), findsOneWidget);
  });

  testWidgets('step controls how much is added/removed', (tester) async {
    int? next;
    await tester.pumpWidget(
      _wrap(MosaicNumberStepper(value: 0, step: 5, onChanged: (v) => next = v)),
    );
    await tester.tap(find.text('+'));
    await tester.pumpAndSettle();
    expect(next, 5);
  });
}
