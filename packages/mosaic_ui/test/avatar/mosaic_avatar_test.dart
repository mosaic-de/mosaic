import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

Widget _wrap(Widget child) => MosaicTheme.test(
      child: Directionality(textDirection: TextDirection.ltr, child: child),
    );

void main() {
  testWidgets('renders two-letter initials from a full name', (tester) async {
    await tester.pumpWidget(_wrap(const MosaicAvatar(name: 'John Simiyu')));
    expect(find.text('JS'), findsOneWidget);
  });

  testWidgets('renders one-letter initials from a single name',
      (tester) async {
    await tester.pumpWidget(_wrap(const MosaicAvatar(name: 'cher')));
    expect(find.text('C'), findsOneWidget);
  });

  testWidgets('child wins over name when both are provided', (tester) async {
    await tester.pumpWidget(_wrap(const MosaicAvatar(
      name: 'John Simiyu',
      child: Text('X'),
    )));
    expect(find.text('JS'), findsNothing);
    expect(find.text('X'), findsOneWidget);
  });

  testWidgets('size token maps to a fixed pixel size', (tester) async {
    await tester.pumpWidget(_wrap(const MosaicAvatar(
      name: 'A',
      size: MosaicAvatarSize.lg,
    )));
    final container = tester.widget<Container>(find.byType(Container));
    expect(container.constraints, const BoxConstraints.tightFor(
      width: 48,
      height: 48,
    ));
  });

  testWidgets('background override beats token', (tester) async {
    const override = Color(0xFF112233);
    await tester.pumpWidget(_wrap(const MosaicAvatar(
      name: 'A',
      background: override,
    )));
    final container = tester.widget<Container>(find.byType(Container));
    expect(container.color, override);
  });
}
