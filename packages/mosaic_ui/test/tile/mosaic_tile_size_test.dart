import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

void main() {
  group('MosaicTileSize', () {
    test('semantic spans match the spec', () {
      expect(MosaicTileSize.small.cols, 1);
      expect(MosaicTileSize.small.rows, 1);
      expect(MosaicTileSize.medium.cols, 2);
      expect(MosaicTileSize.medium.rows, 2);
      expect(MosaicTileSize.wide.cols, 4);
      expect(MosaicTileSize.wide.rows, 2);
      expect(MosaicTileSize.tall.cols, 2);
      expect(MosaicTileSize.tall.rows, 4);
      expect(MosaicTileSize.large.cols, 4);
      expect(MosaicTileSize.large.rows, 4);
      expect(MosaicTileSize.hero.cols, 4);
      expect(MosaicTileSize.hero.rows, 6);
    });

    test('cells equals cols * rows', () {
      for (final size in MosaicTileSize.values) {
        expect(size.cells, size.cols * size.rows);
      }
    });
  });
}
