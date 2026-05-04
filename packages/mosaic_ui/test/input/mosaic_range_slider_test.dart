import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

Widget _wrap(Widget child) {
  return MosaicTheme.test(
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Center(child: SizedBox(width: 200, child: child)),
    ),
  );
}

void main() {
  testWidgets('tap near start moves the start thumb', (tester) async {
    double? lastStart;
    double? lastEnd;
    await tester.pumpWidget(
      _wrap(
        MosaicRangeSlider(
          start: 0.2,
          end: 0.8,
          min: 0,
          max: 1,
          onChanged: (s, e) {
            lastStart = s;
            lastEnd = e;
          },
        ),
      ),
    );
    final box = tester.getRect(find.byType(MosaicRangeSlider));
    // 10% from the left — closer to start (0.2)
    await tester.tapAt(Offset(box.left + box.width * 0.1, box.center.dy));
    await tester.pumpAndSettle();
    expect(lastEnd, 0.8);
    expect(lastStart, closeTo(0.1, 0.02));
  });

  testWidgets('tap near end moves the end thumb', (tester) async {
    double? lastStart;
    double? lastEnd;
    await tester.pumpWidget(
      _wrap(
        MosaicRangeSlider(
          start: 0.2,
          end: 0.8,
          min: 0,
          max: 1,
          onChanged: (s, e) {
            lastStart = s;
            lastEnd = e;
          },
        ),
      ),
    );
    final box = tester.getRect(find.byType(MosaicRangeSlider));
    await tester.tapAt(Offset(box.left + box.width * 0.95, box.center.dy));
    await tester.pumpAndSettle();
    expect(lastStart, 0.2);
    expect(lastEnd, closeTo(0.95, 0.02));
  });

  testWidgets('disabled blocks emission', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      _wrap(
        MosaicRangeSlider(
          start: 0.2,
          end: 0.8,
          enabled: false,
          onChanged: (_, _) => calls++,
        ),
      ),
    );
    final box = tester.getRect(find.byType(MosaicRangeSlider));
    await tester.tapAt(box.center);
    await tester.pumpAndSettle();
    expect(calls, 0);
  });
}
