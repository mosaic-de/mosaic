import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

Widget _wrap(Widget child) => MosaicTheme.test(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: MediaQuery(
          data: const MediaQueryData(size: Size(360, 640)),
          child: Center(
            child: SizedBox(width: 320, child: child),
          ),
        ),
      ),
    );

void main() {
  testWidgets('header tap toggles expansion and fires onChanged',
      (tester) async {
    var open = false;
    await tester.pumpWidget(_wrap(MosaicAccordion(
      title: 'Details',
      onChanged: (v) => open = v,
      child: const Text('hidden body'),
    )));

    expect(find.text('hidden body'), findsNothing);
    await tester.tap(find.text('Details'));
    await tester.pumpAndSettle();
    expect(open, isTrue);
    expect(find.text('hidden body'), findsOneWidget);

    await tester.tap(find.text('Details'));
    await tester.pumpAndSettle();
    expect(open, isFalse);
  });

  testWidgets('initiallyExpanded shows body on first frame', (tester) async {
    await tester.pumpWidget(_wrap(const MosaicAccordion(
      title: 'Open',
      initiallyExpanded: true,
      child: Text('body'),
    )));
    await tester.pumpAndSettle();
    expect(find.text('body'), findsOneWidget);
  });
}
