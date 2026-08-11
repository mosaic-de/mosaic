import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

Widget _wrap(Widget child) => MosaicTheme.test(
  child: Directionality(
    textDirection: TextDirection.ltr,
    child: Center(child: child),
  ),
);

void main() {
  testWidgets('renders at the configured size', (tester) async {
    await tester.pumpWidget(
      _wrap(const MosaicSkeleton(width: 120, height: 24)),
    );
    final box = tester.widget<SizedBox>(
      find.byWidgetPredicate(
        (w) => w is SizedBox && w.width == 120 && w.height == 24,
      ),
    );
    expect(box.width, 120);
  });

  testWidgets('avatar variant is square', (tester) async {
    await tester.pumpWidget(_wrap(const MosaicSkeleton.avatar(size: 48)));
    final box = tester.widget<SizedBox>(
      find.byWidgetPredicate(
        (w) => w is SizedBox && w.width == 48 && w.height == 48,
      ),
    );
    expect(box.height, 48);
  });

  testWidgets('does not throw when motion is disabled', (tester) async {
    await tester.pumpWidget(_wrap(const MosaicSkeleton(width: 80, height: 80)));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
