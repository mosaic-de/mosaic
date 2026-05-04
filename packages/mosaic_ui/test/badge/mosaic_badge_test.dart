import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

Widget _wrap(Widget child) => MosaicTheme.test(
      child: Directionality(textDirection: TextDirection.ltr, child: child),
    );

void main() {
  testWidgets('renders the label', (tester) async {
    await tester.pumpWidget(_wrap(const MosaicBadge(label: 'NEW')));
    expect(find.text('NEW'), findsOneWidget);
  });

  testWidgets('error tone uses the error color token', (tester) async {
    await tester.pumpWidget(_wrap(const MosaicBadge(
      label: '3',
      tone: MosaicBadgeTone.error,
    )));
    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration as BoxDecoration;
    final tokens = MosaicTokens.metro();
    expect(decoration.color, tokens.color.error);
  });

  testWidgets('color override beats tone', (tester) async {
    const override = Color(0xFFAABBCC);
    await tester.pumpWidget(_wrap(const MosaicBadge(
      label: 'X',
      tone: MosaicBadgeTone.error,
      color: override,
    )));
    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, override);
  });

  testWidgets('dot has no label and a fixed size', (tester) async {
    await tester.pumpWidget(_wrap(const MosaicBadge.dot()));
    expect(find.byType(Text), findsNothing);
    final container = tester.widget<Container>(find.byType(Container));
    expect(container.constraints, const BoxConstraints.tightFor(
      width: 8,
      height: 8,
    ));
  });
}
