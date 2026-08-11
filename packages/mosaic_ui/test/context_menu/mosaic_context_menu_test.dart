import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

Widget _wrap(Widget child) => MosaicTheme.test(
  child: Directionality(
    textDirection: TextDirection.ltr,
    child: Overlay(initialEntries: [OverlayEntry(builder: (_) => child)]),
  ),
);

void main() {
  testWidgets('long-press shows the action list', (tester) async {
    await tester.pumpWidget(
      _wrap(
        Center(
          child: MosaicContextMenu(
            actions: [
              MosaicContextAction(label: 'Edit', onPressed: () {}),
              MosaicContextAction(
                label: 'Delete',
                destructive: true,
                onPressed: () {},
              ),
            ],
            child: Container(
              width: 80,
              height: 80,
              color: const Color(0xFFAAAAAA),
              alignment: Alignment.center,
              child: const Text('anchor'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Edit'), findsNothing);
    await tester.longPress(find.text('anchor'));
    await tester.pumpAndSettle();
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('tapping an action fires it and dismisses the menu', (
    tester,
  ) async {
    var fired = 0;
    await tester.pumpWidget(
      _wrap(
        Center(
          child: MosaicContextMenu(
            actions: [
              MosaicContextAction(label: 'Run', onPressed: () => fired += 1),
            ],
            child: const Text('anchor'),
          ),
        ),
      ),
    );
    await tester.longPress(find.text('anchor'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Run'));
    await tester.pumpAndSettle();
    expect(fired, 1);
    expect(find.text('Run'), findsNothing);
  });
}
