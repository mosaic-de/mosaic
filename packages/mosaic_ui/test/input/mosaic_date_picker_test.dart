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
  testWidgets('shows placeholder when value is null', (tester) async {
    await tester.pumpWidget(
      _wrap(
        MosaicDatePicker(
          value: null,
          onChanged: (_) {},
          placeholder: 'Pick a date',
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Pick a date'), findsOneWidget);
  });

  testWidgets('shows formatted value when set', (tester) async {
    await tester.pumpWidget(
      _wrap(MosaicDatePicker(value: DateTime(2026, 5, 15), onChanged: (_) {})),
    );
    await tester.pumpAndSettle();
    expect(find.text('15 / 05 / 2026'), findsOneWidget);
  });

  testWidgets('tapping pushes a panel; picking fires onChanged and pops', (
    tester,
  ) async {
    DateTime? captured;
    await tester.pumpWidget(
      _wrap(
        MosaicDatePicker(
          value: DateTime(2026, 5, 15),
          onChanged: (d) => captured = d,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Open the panel.
    await tester.tap(find.byType(MosaicDatePicker));
    await tester.pumpAndSettle();
    expect(find.text('Date'), findsOneWidget);
    expect(find.text('May 2026'), findsOneWidget);

    // Pick a different day.
    await tester.tap(find.text('20'));
    await tester.pumpAndSettle();

    expect(captured, DateTime(2026, 5, 20));
    // Panel collapsed.
    expect(find.text('May 2026'), findsNothing);
  });

  testWidgets('custom formatter wins over default', (tester) async {
    await tester.pumpWidget(
      _wrap(
        MosaicDatePicker(
          value: DateTime(2026, 5, 15),
          onChanged: (_) {},
          formatter: (d) => '${d.day} May',
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('15 May'), findsOneWidget);
  });
}
