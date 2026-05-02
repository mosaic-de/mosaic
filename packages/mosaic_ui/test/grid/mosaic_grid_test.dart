import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

void main() {
  testWidgets('packs a row of small tiles left-to-right', (tester) async {
    final tiles = <MosaicTileWidget>[
      const MosaicTile(
        key: Key('a'),
        size: MosaicTileSize.small,
        child: SizedBox.shrink(),
      ),
      const MosaicTile(
        key: Key('b'),
        size: MosaicTileSize.small,
        child: SizedBox.shrink(),
      ),
      const MosaicTile(
        key: Key('c'),
        size: MosaicTileSize.small,
        child: SizedBox.shrink(),
      ),
      const MosaicTile(
        key: Key('d'),
        size: MosaicTileSize.small,
        child: SizedBox.shrink(),
      ),
    ];

    await tester.pumpWidget(
      MosaicTheme.test(
        child: SizedBox(
          width: 400,
          height: 400,
          child: MosaicGrid(crossAxisCount: 4, children: tiles),
        ),
      ),
    );

    final aTop = tester.getTopLeft(find.byKey(const Key('a')));
    final dTop = tester.getTopLeft(find.byKey(const Key('d')));
    expect(aTop.dy, dTop.dy, reason: 'all four should sit on row 0');
    expect(dTop.dx, greaterThan(aTop.dx));
  });

  testWidgets('wraps to a new row when current row cannot fit', (tester) async {
    final tiles = <MosaicTileWidget>[
      const MosaicTile(
        key: Key('wide'),
        size: MosaicTileSize.wide, // 4x2
        child: SizedBox.shrink(),
      ),
      const MosaicTile(
        key: Key('next'),
        size: MosaicTileSize.small, // 1x1
        child: SizedBox.shrink(),
      ),
    ];

    await tester.pumpWidget(
      MosaicTheme.test(
        child: SizedBox(
          width: 400,
          height: 400,
          child: MosaicGrid(crossAxisCount: 4, children: tiles),
        ),
      ),
    );

    final wideTop = tester.getTopLeft(find.byKey(const Key('wide')));
    final nextTop = tester.getTopLeft(find.byKey(const Key('next')));
    expect(wideTop.dy, 0);
    expect(
      nextTop.dy,
      greaterThan(wideTop.dy),
      reason: 'wide tile fills row 0-1, next tile starts on row 2',
    );
  });

  testWidgets('respects gutter override', (tester) async {
    final tiles = <MosaicTileWidget>[
      const MosaicTile(
        key: Key('a'),
        size: MosaicTileSize.small,
        child: SizedBox.shrink(),
      ),
      const MosaicTile(
        key: Key('b'),
        size: MosaicTileSize.small,
        child: SizedBox.shrink(),
      ),
    ];

    await tester.pumpWidget(
      MosaicTheme.test(
        child: SizedBox(
          width: 400,
          height: 400,
          child: MosaicGrid(crossAxisCount: 4, gutter: 20, children: tiles),
        ),
      ),
    );

    final a = tester.getTopLeft(find.byKey(const Key('a')));
    final b = tester.getTopLeft(find.byKey(const Key('b')));
    final aSize = tester.getSize(find.byKey(const Key('a')));
    expect(b.dx - a.dx - aSize.width, closeTo(20, 0.5));
  });

  testWidgets('places a tall tile and continues filling beside it', (
    tester,
  ) async {
    final tiles = <MosaicTileWidget>[
      const MosaicTile(
        key: Key('tall'),
        size: MosaicTileSize.tall, // 2x4
        child: SizedBox.shrink(),
      ),
      const MosaicTile(
        key: Key('beside'),
        size: MosaicTileSize.medium, // 2x2
        child: SizedBox.shrink(),
      ),
    ];

    await tester.pumpWidget(
      MosaicTheme.test(
        child: SizedBox(
          width: 400,
          height: 400,
          child: MosaicGrid(crossAxisCount: 4, children: tiles),
        ),
      ),
    );

    final tallTop = tester.getTopLeft(find.byKey(const Key('tall')));
    final besideTop = tester.getTopLeft(find.byKey(const Key('beside')));
    expect(tallTop.dx, 0);
    expect(tallTop.dy, 0);
    expect(
      besideTop.dx,
      greaterThan(tallTop.dx),
      reason: 'medium should be placed to the right of tall',
    );
    expect(besideTop.dy, tallTop.dy);
  });
}
