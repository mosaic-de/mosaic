import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

Widget _wrap(Widget child) {
  return MosaicTheme.test(
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Center(child: SizedBox(width: 320, height: 380, child: child)),
    ),
  );
}

void main() {
  testWidgets('renders the month label and day grid', (tester) async {
    await tester.pumpWidget(
      _wrap(MosaicCalendar(selected: DateTime(2026, 5, 15), onChanged: (_) {})),
    );
    expect(find.text('May 2026'), findsOneWidget);
    expect(find.text('15'), findsOneWidget);
  });

  testWidgets('tapping a day fires onChanged', (tester) async {
    DateTime? captured;
    await tester.pumpWidget(
      _wrap(
        MosaicCalendar(
          selected: DateTime(2026, 5, 15),
          onChanged: (d) => captured = d,
        ),
      ),
    );
    await tester.tap(find.text('20'));
    await tester.pumpAndSettle();
    expect(captured, DateTime(2026, 5, 20));
  });

  testWidgets('previous arrow moves to last month', (tester) async {
    await tester.pumpWidget(
      _wrap(MosaicCalendar(selected: DateTime(2026, 5, 15), onChanged: (_) {})),
    );
    await tester.tap(find.text('‹'));
    await tester.pumpAndSettle();
    expect(find.text('April 2026'), findsOneWidget);
  });

  testWidgets('next arrow moves to following month', (tester) async {
    await tester.pumpWidget(
      _wrap(MosaicCalendar(selected: DateTime(2026, 5, 15), onChanged: (_) {})),
    );
    await tester.tap(find.text('›'));
    await tester.pumpAndSettle();
    expect(find.text('June 2026'), findsOneWidget);
  });

  testWidgets('day before firstDay is disabled', (tester) async {
    DateTime? captured;
    await tester.pumpWidget(
      _wrap(
        MosaicCalendar(
          selected: DateTime(2026, 5, 15),
          firstDay: DateTime(2026, 5, 10),
          onChanged: (d) => captured = d,
        ),
      ),
    );
    await tester.tap(find.text('5'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(captured, isNull);
  });
}
