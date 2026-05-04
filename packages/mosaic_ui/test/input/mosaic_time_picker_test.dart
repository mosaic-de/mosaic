import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

Widget _wrap(Widget child) {
  return MosaicApp(
    motionScale: 0,
    builder: (context) => MosaicSurfaceHost(
      body: Center(child: SizedBox(width: 360, child: child)),
    ),
  );
}

void main() {
  testWidgets('shows placeholder when null', (tester) async {
    await tester.pumpWidget(
      _wrap(MosaicTimePicker(value: null, onChanged: (_) {})),
    );
    await tester.pumpAndSettle();
    expect(find.text('Pick a time'), findsOneWidget);
  });

  testWidgets('formats 12-hour value with AM/PM', (tester) async {
    await tester.pumpWidget(
      _wrap(
        MosaicTimePicker(
          value: const TimeOfDay(hour: 14, minute: 30),
          onChanged: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('2:30 PM'), findsOneWidget);
  });

  testWidgets('formats 24-hour value when use24Hour is true', (tester) async {
    await tester.pumpWidget(
      _wrap(
        MosaicTimePicker(
          value: const TimeOfDay(hour: 14, minute: 30),
          use24Hour: true,
          onChanged: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('14:30'), findsOneWidget);
  });

  testWidgets('tap pushes panel; confirm fires onChanged and pops', (
    tester,
  ) async {
    TimeOfDay? captured;
    await tester.pumpWidget(
      _wrap(
        MosaicTimePicker(
          value: const TimeOfDay(hour: 9, minute: 0),
          onChanged: (t) => captured = t,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(MosaicTimePicker));
    await tester.pumpAndSettle();
    expect(find.text('Time'), findsOneWidget);

    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(captured, const TimeOfDay(hour: 9, minute: 0));
    expect(find.text('Time'), findsNothing);
  });

  test('TimeOfDay equality', () {
    expect(
      const TimeOfDay(hour: 9, minute: 30),
      const TimeOfDay(hour: 9, minute: 30),
    );
    expect(
      const TimeOfDay(hour: 9, minute: 30),
      isNot(const TimeOfDay(hour: 9, minute: 31)),
    );
  });
}
