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
  testWidgets('header scrolls so the active label is on screen', (
    tester,
  ) async {
    // Regression. The header is a horizontal scroll view that nothing
    // ever scrolled: labels lay out left to right and the strip stayed
    // at offset zero, so on a narrow phone swiping to a later page left
    // that page's own title off-screen — the one word the user most
    // needs to see. Reported from a consumer app on a 400px screen.
    //
    // Driven entirely by swiping the pages, never by tapping a label,
    // because a label that has scrolled off cannot be tapped. That is
    // the bug, so a test that reached for it would be testing the fix
    // with the fix already assumed.
    const width = 360.0;
    await tester.binding.setSurfaceSize(const Size(width, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MosaicTheme.test(
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: width,
            height: 640,
            child: MosaicPivot(
              pages: const [
                MosaicPivotPage(label: 'settings', child: Text('one')),
                MosaicPivotPage(label: 'applications', child: Text('two')),
                MosaicPivotPage(label: 'notifications', child: Text('three')),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // The later labels start beyond the right edge — that is the setup,
    // not the failure.
    expect(
      tester.getTopLeft(find.text('notifications')).dx,
      greaterThan(width),
    );

    Future<void> swipeToNextPage(String visiblePageText) async {
      await tester.drag(find.text(visiblePageText), const Offset(-width, 0));
      await tester.pumpAndSettle();
    }

    await swipeToNextPage('one');
    final second = tester.getTopLeft(find.text('applications')).dx;
    expect(second, lessThan(width), reason: 'header must follow the page');
    expect(second, greaterThanOrEqualTo(0));

    await swipeToNextPage('two');
    final third = tester.getTopLeft(find.text('notifications')).dx;
    expect(third, lessThan(width), reason: 'header must follow the page');
    expect(third, greaterThanOrEqualTo(0));
  });

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
