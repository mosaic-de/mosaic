import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

Widget _wrap(Widget child) {
  return MosaicTheme.test(
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Center(child: SizedBox(width: 720, height: 480, child: child)),
    ),
  );
}

void main() {
  testWidgets('renders the active page initially', (tester) async {
    await tester.pumpWidget(
      _wrap(
        MosaicPivot(
          pages: const [
            MosaicPivotPage(
              label: 'Day',
              child: Text('day-body', textDirection: TextDirection.ltr),
            ),
            MosaicPivotPage(
              label: 'Week',
              child: Text('week-body', textDirection: TextDirection.ltr),
            ),
          ],
        ),
      ),
    );

    expect(find.text('Day'), findsOneWidget);
    expect(find.text('Week'), findsOneWidget);
    expect(find.text('day-body'), findsOneWidget);
  });

  testWidgets('respects initialIndex', (tester) async {
    await tester.pumpWidget(
      _wrap(
        MosaicPivot(
          initialIndex: 1,
          pages: const [
            MosaicPivotPage(
              label: 'Day',
              child: Text('day-body', textDirection: TextDirection.ltr),
            ),
            MosaicPivotPage(
              label: 'Week',
              child: Text('week-body', textDirection: TextDirection.ltr),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('week-body'), findsOneWidget);
  });

  testWidgets('tapping a label switches the active page', (tester) async {
    var changes = 0;
    int? lastIndex;
    await tester.pumpWidget(
      _wrap(
        MosaicPivot(
          onIndexChanged: (i) {
            changes++;
            lastIndex = i;
          },
          pages: const [
            MosaicPivotPage(
              label: 'Day',
              child: Text('day-body', textDirection: TextDirection.ltr),
            ),
            MosaicPivotPage(
              label: 'Week',
              child: Text('week-body', textDirection: TextDirection.ltr),
            ),
            MosaicPivotPage(
              label: 'Agenda',
              child: Text('agenda-body', textDirection: TextDirection.ltr),
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.text('Agenda'));
    await tester.pumpAndSettle();

    expect(changes, 1);
    expect(lastIndex, 2);
    expect(find.text('agenda-body'), findsOneWidget);
  });

  testWidgets('tapping the already-active label is a no-op', (tester) async {
    var changes = 0;
    await tester.pumpWidget(
      _wrap(
        MosaicPivot(
          onIndexChanged: (_) => changes++,
          pages: const [
            MosaicPivotPage(
              label: 'Day',
              child: Text('day-body', textDirection: TextDirection.ltr),
            ),
            MosaicPivotPage(
              label: 'Week',
              child: Text('week-body', textDirection: TextDirection.ltr),
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.text('Day'));
    await tester.pumpAndSettle();
    expect(changes, 0);
  });
}
