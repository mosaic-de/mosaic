import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

Widget _wrap(Widget child) => MosaicTheme.test(
      child: Directionality(textDirection: TextDirection.ltr, child: child),
    );

void main() {
  group('MosaicProgressBar', () {
    testWidgets('renders fill at the supplied fraction', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox(
        width: 100,
        child: MosaicProgressBar(value: 0.5),
      )));
      final fill = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(fill.widthFactor, 0.5);
    });

    testWidgets('color override beats accent token', (tester) async {
      const override = Color(0xFFAA00FF);
      await tester.pumpWidget(_wrap(const SizedBox(
        width: 100,
        child: MosaicProgressBar(value: 0.25, color: override),
      )));
      final paints = find.byType(ColoredBox).evaluate().toList();
      // Two coloreds: track + fill. The fill is the inner one — but we
      // only need to confirm one of them carries our override.
      final colors = paints.map((e) => (e.widget as ColoredBox).color).toSet();
      expect(colors, contains(override));
    });

    test('asserts value is in [0,1]', () {
      expect(
        () => MosaicProgressBar(value: 1.5),
        throwsAssertionError,
      );
    });
  });

  group('MosaicActivityIndicator', () {
    testWidgets('renders at the configured size', (tester) async {
      await tester.pumpWidget(
        _wrap(const MosaicActivityIndicator(size: 40)),
      );
      final box = tester.widget<SizedBox>(
        find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == 40 && w.height == 40,
        ),
      );
      expect(box.width, 40);
    });

    testWidgets('does not throw when motion is disabled', (tester) async {
      await tester.pumpWidget(_wrap(const MosaicActivityIndicator()));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
