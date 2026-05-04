import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

Widget _wrap(Widget child) => MosaicTheme.test(
      child: Directionality(textDirection: TextDirection.ltr, child: child),
    );

void main() {
  testWidgets('count overlay renders the value', (tester) async {
    await tester.pumpWidget(_wrap(const MosaicBadgeOverlay(
      count: 7,
      child: SizedBox(width: 40, height: 40),
    )));
    expect(find.text('7'), findsOneWidget);
  });

  testWidgets('zero count hides the badge by default', (tester) async {
    await tester.pumpWidget(_wrap(const MosaicBadgeOverlay(
      count: 0,
      child: SizedBox(width: 40, height: 40),
    )));
    expect(find.byType(MosaicBadge), findsNothing);
  });

  testWidgets('zero count is shown when showWhenZero is true',
      (tester) async {
    await tester.pumpWidget(_wrap(const MosaicBadgeOverlay(
      count: 0,
      showWhenZero: true,
      child: SizedBox(width: 40, height: 40),
    )));
    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('count above maxCount is capped', (tester) async {
    await tester.pumpWidget(_wrap(const MosaicBadgeOverlay(
      count: 250,
      maxCount: 99,
      child: SizedBox(width: 40, height: 40),
    )));
    expect(find.text('99+'), findsOneWidget);
  });

  testWidgets('label takes precedence over count', (tester) async {
    await tester.pumpWidget(_wrap(const MosaicBadgeOverlay(
      label: 'NEW',
      count: 3,
      child: SizedBox(width: 40, height: 40),
    )));
    expect(find.text('NEW'), findsOneWidget);
    expect(find.text('3'), findsNothing);
  });
}
