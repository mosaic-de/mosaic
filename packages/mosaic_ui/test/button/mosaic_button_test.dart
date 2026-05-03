import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

Widget _wrap(Widget child) {
  return MosaicTheme.test(
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Center(child: SizedBox(width: 240, child: child)),
    ),
  );
}

void main() {
  testWidgets('renders label', (tester) async {
    await tester.pumpWidget(
      _wrap(MosaicButton(label: 'Send', onPressed: () {})),
    );
    expect(find.text('Send'), findsOneWidget);
  });

  testWidgets('fires onPressed', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(MosaicButton(label: 'Send', onPressed: () => taps++)),
    );
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();
    expect(taps, 1);
  });

  testWidgets('disabled blocks tap', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(
        MosaicButton(label: 'Send', enabled: false, onPressed: () => taps++),
      ),
    );
    await tester.tap(find.text('Send'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(taps, 0);
  });

  testWidgets('primary kind paints accent background', (tester) async {
    await tester.pumpWidget(
      _wrap(MosaicButton(label: 'Send', onPressed: () {})),
    );
    final tokens = MosaicTokens.metro(motionScale: 0);
    final container = tester.widgetList<Container>(find.byType(Container)).last;
    final dec = container.decoration! as BoxDecoration;
    expect(dec.color, tokens.color.accent);
  });

  testWidgets('ghost kind has transparent fill', (tester) async {
    await tester.pumpWidget(
      _wrap(
        MosaicButton(
          label: 'Cancel',
          kind: MosaicButtonKind.ghost,
          onPressed: () {},
        ),
      ),
    );
    final container = tester.widgetList<Container>(find.byType(Container)).last;
    final dec = container.decoration! as BoxDecoration;
    expect(dec.color, const Color(0x00000000));
  });
}
