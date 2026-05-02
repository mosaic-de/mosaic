/// Semantic tile sizes. Each maps to a fixed (cols, rows) span against
/// the grid. Anything outside this enum is forbidden by Mosaic — random
/// masonry breaks the strict-grid contract.
enum MosaicTileSize {
  /// 1x1 — icon or status only.
  small(1, 1),

  /// 2x2 — app, action, or state preview.
  medium(2, 2),

  /// 4x2 — text-heavy live state across a full row.
  wide(4, 2),

  /// 2x4 — vertical timeline, feed, or content column.
  tall(2, 4),

  /// 4x4 — dashboard summary block.
  large(4, 4),

  /// 4x6 — primary screen focus.
  hero(4, 6);

  const MosaicTileSize(this.cols, this.rows);

  final int cols;
  final int rows;

  int get cells => cols * rows;
}
