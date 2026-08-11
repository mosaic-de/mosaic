import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

Widget _wrap(Widget child) => MosaicTheme.test(
  child: MediaQuery(
    data: const MediaQueryData(size: Size(600, 800)),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Overlay(
        initialEntries: [OverlayEntry(builder: (_) => Center(child: child))],
      ),
    ),
  ),
);

void main() {
  testWidgets('reorderable grid renders all children with their keys', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 400,
          child: MosaicReorderableGrid(
            crossAxisCount: 4,
            onReorder: (_, _) {},
            children: [
              for (var i = 0; i < 4; i++)
                MosaicTile(
                  key: ValueKey('tile.$i'),
                  size: MosaicTileSize.medium,
                  child: Center(child: Text('$i')),
                ),
            ],
          ),
        ),
      ),
    );
    for (var i = 0; i < 4; i++) {
      expect(find.text('$i'), findsOneWidget);
    }
  });

  testWidgets('disabled grid does not call onReorder', (tester) async {
    var called = 0;
    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 400,
          child: MosaicReorderableGrid(
            crossAxisCount: 4,
            enabled: false,
            longPress: false,
            onReorder: (_, _) => called += 1,
            children: [
              for (var i = 0; i < 4; i++)
                MosaicTile(
                  key: ValueKey('tile.$i'),
                  size: MosaicTileSize.medium,
                  child: Center(child: Text('$i')),
                ),
            ],
          ),
        ),
      ),
    );
    final src = tester.getCenter(find.text('0'));
    final dst = tester.getCenter(find.text('3'));
    final gesture = await tester.startGesture(src);
    await gesture.moveTo(dst);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(called, 0);
  });
}
