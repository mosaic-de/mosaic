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
  testWidgets('tap on track emits a value', (tester) async {
    double? last;
    await tester.pumpWidget(
      _wrap(
        MosaicSlider(value: 0, min: 0, max: 100, onChanged: (v) => last = v),
      ),
    );
    final slider = find.byType(MosaicSlider);
    final box = tester.getRect(slider);
    await tester.tapAt(Offset(box.left + box.width / 2, box.center.dy));
    await tester.pumpAndSettle();
    expect(last, isNotNull);
    expect(last, closeTo(50, 1));
  });

  testWidgets('divisions snap to ticks', (tester) async {
    double? last;
    await tester.pumpWidget(
      _wrap(
        MosaicSlider(
          value: 0,
          min: 0,
          max: 100,
          divisions: 4,
          onChanged: (v) => last = v,
        ),
      ),
    );
    final slider = find.byType(MosaicSlider);
    final box = tester.getRect(slider);
    // Tap roughly at 60% — with divisions=4 (steps of 25), the closest
    // tick is 50.
    await tester.tapAt(Offset(box.left + box.width * 0.6, box.center.dy));
    await tester.pumpAndSettle();
    expect(last, anyOf(50.0, 75.0));
  });

  testWidgets('disabled blocks emission', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      _wrap(
        MosaicSlider(
          value: 0,
          min: 0,
          max: 100,
          enabled: false,
          onChanged: (_) => calls++,
        ),
      ),
    );
    final box = tester.getRect(find.byType(MosaicSlider));
    await tester.tapAt(Offset(box.center.dx, box.center.dy));
    await tester.pumpAndSettle();
    expect(calls, 0);
  });
}
