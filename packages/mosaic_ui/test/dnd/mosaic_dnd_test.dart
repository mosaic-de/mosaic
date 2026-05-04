import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

Widget _wrap(Widget child) => MosaicTheme.test(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Overlay(
          initialEntries: [
            OverlayEntry(builder: (_) => child),
          ],
        ),
      ),
    );

void main() {
  testWidgets('drop target accepts a draggable payload', (tester) async {
    int? received;
    await tester.pumpWidget(_wrap(Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MosaicDraggable<int>(
            data: 7,
            longPress: false,
            child: Container(
              key: const ValueKey('source'),
              width: 80,
              height: 80,
              color: const Color(0xFFAAAAAA),
            ),
          ),
          const SizedBox(height: 60),
          MosaicDropTarget<int>(
            onAccept: (v) => received = v,
            child: Container(
              key: const ValueKey('target'),
              width: 80,
              height: 80,
              color: const Color(0xFFCCCCCC),
            ),
          ),
        ],
      ),
    )));

    final src = tester.getCenter(find.byKey(const ValueKey('source')));
    final dst = tester.getCenter(find.byKey(const ValueKey('target')));
    final gesture = await tester.startGesture(src);
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.moveTo(dst);
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(received, 7);
  });

  testWidgets('disabled draggable does not start a drag', (tester) async {
    int? received;
    await tester.pumpWidget(_wrap(Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MosaicDraggable<int>(
            data: 1,
            longPress: false,
            enabled: false,
            child: Container(
              key: const ValueKey('source'),
              width: 80,
              height: 80,
              color: const Color(0xFFAAAAAA),
            ),
          ),
          const SizedBox(height: 60),
          MosaicDropTarget<int>(
            onAccept: (v) => received = v,
            child: Container(
              key: const ValueKey('target'),
              width: 80,
              height: 80,
              color: const Color(0xFFCCCCCC),
            ),
          ),
        ],
      ),
    )));
    final src = tester.getCenter(find.byKey(const ValueKey('source')));
    final dst = tester.getCenter(find.byKey(const ValueKey('target')));
    final gesture = await tester.startGesture(src);
    await gesture.moveTo(dst);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(received, isNull);
  });
}
