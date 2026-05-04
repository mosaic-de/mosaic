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
  testWidgets('renders all segment labels', (tester) async {
    await tester.pumpWidget(
      _wrap(
        MosaicSegmented<String>(
          value: 'a',
          onChanged: (_) {},
          segments: const [
            MosaicSegment(value: 'a', label: 'Day'),
            MosaicSegment(value: 'b', label: 'Week'),
            MosaicSegment(value: 'c', label: 'Month'),
          ],
        ),
      ),
    );
    expect(find.text('Day'), findsOneWidget);
    expect(find.text('Week'), findsOneWidget);
    expect(find.text('Month'), findsOneWidget);
  });

  testWidgets('tapping a segment fires onChanged with its value', (
    tester,
  ) async {
    String? captured;
    await tester.pumpWidget(
      _wrap(
        MosaicSegmented<String>(
          value: 'a',
          onChanged: (v) => captured = v,
          segments: const [
            MosaicSegment(value: 'a', label: 'Day'),
            MosaicSegment(value: 'b', label: 'Week'),
          ],
        ),
      ),
    );
    await tester.tap(find.text('Week'));
    await tester.pumpAndSettle();
    expect(captured, 'b');
  });

  testWidgets('disabled blocks tap', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      _wrap(
        MosaicSegmented<int>(
          value: 0,
          enabled: false,
          onChanged: (_) => calls++,
          segments: const [
            MosaicSegment(value: 0, label: 'A'),
            MosaicSegment(value: 1, label: 'B'),
          ],
        ),
      ),
    );
    await tester.tap(find.text('B'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(calls, 0);
  });
}
