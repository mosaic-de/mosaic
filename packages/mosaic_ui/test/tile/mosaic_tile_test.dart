import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

void main() {
  testWidgets('MosaicTile renders its child', (tester) async {
    await tester.pumpWidget(
      MosaicTheme.test(
        child: const Center(
          child: SizedBox(
            width: 200,
            height: 200,
            child: MosaicTile(
              size: MosaicTileSize.medium,
              child: Text('hello', textDirection: TextDirection.ltr),
            ),
          ),
        ),
      ),
    );
    expect(find.text('hello'), findsOneWidget);
  });

  testWidgets('MosaicTile fires onPressed', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MosaicTheme.test(
        child: Center(
          child: SizedBox(
            width: 200,
            height: 200,
            child: MosaicTile(
              size: MosaicTileSize.medium,
              onPressed: () => taps++,
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(MosaicTile));
    await tester.pumpAndSettle();
    expect(taps, 1);
  });

  testWidgets('MosaicTile fires onLongPress', (tester) async {
    var longPresses = 0;
    await tester.pumpWidget(
      MosaicTheme.test(
        child: Center(
          child: SizedBox(
            width: 200,
            height: 200,
            child: MosaicTile(
              size: MosaicTileSize.medium,
              onLongPress: () => longPresses++,
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );
    await tester.longPress(find.byType(MosaicTile));
    await tester.pumpAndSettle();
    expect(longPresses, 1);
  });

  testWidgets('MosaicTile implements MosaicTileWidget with correct size', (
    tester,
  ) async {
    const tile = MosaicTile(
      size: MosaicTileSize.wide,
      child: SizedBox.shrink(),
    );
    // ignore: avoid_dynamic_calls
    expect((tile as MosaicTileWidget).size, MosaicTileSize.wide);
  });
}
