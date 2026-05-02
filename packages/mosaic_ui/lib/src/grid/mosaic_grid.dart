import 'package:flutter/widgets.dart';

import '../theme/mosaic_theme.dart';
import '../tile/mosaic_tile_widget.dart';

/// Strict semantic grid. Lays out [MosaicTileWidget] children in
/// declaration order, packing each tile's `size.cols x size.rows` span
/// into the next free cell using row-major first-fit.
///
/// The grid resolves cell dimensions from the available width:
/// `cellSize = (maxWidth - gutter * (cols - 1)) / cols`, so tiles are
/// uniformly square at the unit size and fill horizontal space.
class MosaicGrid extends StatelessWidget {
  const MosaicGrid({
    super.key,
    required this.children,
    this.crossAxisCount,
    this.gutter,
  });

  final List<MosaicTileWidget> children;
  final int? crossAxisCount;
  final double? gutter;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    final cols = crossAxisCount ?? tokens.grid.columnsMobile;
    final g = gutter ?? tokens.grid.gutter;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width.isInfinite || cols <= 0) {
          return const SizedBox.shrink();
        }
        final cell = (width - g * (cols - 1)) / cols;
        final placements = _pack(children, cols);
        if (placements.isEmpty) {
          return const SizedBox.shrink();
        }
        final rows = placements
            .map((p) => p.row + p.tile.size.rows)
            .reduce((a, b) => a > b ? a : b);
        final height = rows * cell + (rows - 1) * g;
        return SizedBox(
          width: width,
          height: height,
          child: Stack(
            alignment: Alignment.topLeft,
            clipBehavior: Clip.none,
            children: [
              for (final p in placements)
                Positioned(
                  left: p.col * (cell + g),
                  top: p.row * (cell + g),
                  width: p.tile.size.cols * cell + (p.tile.size.cols - 1) * g,
                  height: p.tile.size.rows * cell + (p.tile.size.rows - 1) * g,
                  child: p.tile,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Placement {
  const _Placement(this.tile, this.col, this.row);
  final MosaicTileWidget tile;
  final int col;
  final int row;
}

List<_Placement> _pack(List<MosaicTileWidget> tiles, int cols) {
  final occ = <List<bool>>[];
  final out = <_Placement>[];

  void ensureRows(int rows) {
    while (occ.length < rows) {
      occ.add(List<bool>.filled(cols, false));
    }
  }

  bool fits(int row, int col, int cw, int ch) {
    if (col + cw > cols) return false;
    ensureRows(row + ch);
    for (var r = row; r < row + ch; r++) {
      for (var c = col; c < col + cw; c++) {
        if (occ[r][c]) return false;
      }
    }
    return true;
  }

  void mark(int row, int col, int cw, int ch) {
    for (var r = row; r < row + ch; r++) {
      for (var c = col; c < col + cw; c++) {
        occ[r][c] = true;
      }
    }
  }

  for (final tile in tiles) {
    final cw = tile.size.cols;
    final ch = tile.size.rows;
    assert(
      cw <= cols,
      'Tile ${tile.size} is wider than the grid (cols=$cols).',
    );
    var placed = false;
    for (var r = 0; !placed; r++) {
      for (var c = 0; c <= cols - cw; c++) {
        if (fits(r, c, cw, ch)) {
          mark(r, c, cw, ch);
          out.add(_Placement(tile, c, r));
          placed = true;
          break;
        }
      }
    }
  }
  return out;
}
