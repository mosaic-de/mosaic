import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

Widget _wrap(Widget child) {
  return MosaicTheme.test(
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Center(child: SizedBox(width: 320, height: 480, child: child)),
    ),
  );
}

void main() {
  testWidgets('renders title and subtitle', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const MosaicList(
          rows: [
            MosaicListRow(title: 'Java House', subtitle: '2h ago'),
            MosaicListRow(title: 'Uber', subtitle: '1d ago'),
          ],
        ),
      ),
    );
    expect(find.text('Java House'), findsOneWidget);
    expect(find.text('2h ago'), findsOneWidget);
    expect(find.text('Uber'), findsOneWidget);
    expect(find.text('1d ago'), findsOneWidget);
  });

  testWidgets('row without callbacks is non-interactive', (tester) async {
    await tester.pumpWidget(
      _wrap(const MosaicList(rows: [MosaicListRow(title: 'Plain')])),
    );
    expect(find.byType(MosaicPressFeedback), findsNothing);
  });

  testWidgets('row with onPressed gains MosaicPressFeedback and fires it', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(
        MosaicList(
          rows: [MosaicListRow(title: 'Tap me', onPressed: () => taps++)],
        ),
      ),
    );
    expect(find.byType(MosaicPressFeedback), findsOneWidget);
    await tester.tap(find.text('Tap me'));
    await tester.pumpAndSettle();
    expect(taps, 1);
  });

  testWidgets('builder constructor lazily builds rows', (tester) async {
    await tester.pumpWidget(
      _wrap(
        MosaicList.builder(
          itemCount: 50,
          builder: (context, i) => MosaicListRow(title: 'row $i'),
        ),
      ),
    );
    expect(find.text('row 0'), findsOneWidget);
    // far-out row not yet realized in viewport
    expect(find.text('row 49'), findsNothing);
  });

  testWidgets('disabled row blocks taps', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(
        MosaicList(
          rows: [
            MosaicListRow(
              title: 'Disabled',
              enabled: false,
              onPressed: () => taps++,
            ),
          ],
        ),
      ),
    );
    await tester.tap(find.text('Disabled'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(taps, 0);
  });
}
