import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

Widget _wrap(Widget child) => MosaicTheme.test(
      child: Directionality(textDirection: TextDirection.ltr, child: child),
    );

void main() {
  testWidgets('horizontal divider has the configured thickness',
      (tester) async {
    await tester.pumpWidget(_wrap(const SizedBox(
      width: 100,
      child: MosaicDivider(thickness: 3),
    )));
    final box = tester.widget<SizedBox>(
      find.byWidgetPredicate(
        (w) => w is SizedBox && w.height == 3,
      ),
    );
    expect(box.height, 3);
  });

  testWidgets('vertical divider has the configured thickness',
      (tester) async {
    await tester.pumpWidget(_wrap(const SizedBox(
      height: 100,
      child: MosaicDivider.vertical(thickness: 2),
    )));
    final box = tester.widget<SizedBox>(
      find.byWidgetPredicate(
        (w) => w is SizedBox && w.width == 2,
      ),
    );
    expect(box.width, 2);
  });

  testWidgets('color override beats divider token', (tester) async {
    const override = Color(0xFFFF0000);
    await tester.pumpWidget(_wrap(const SizedBox(
      width: 100,
      child: MosaicDivider(color: override),
    )));
    final colored = tester.widget<ColoredBox>(find.byType(ColoredBox));
    expect(colored.color, override);
  });
}
