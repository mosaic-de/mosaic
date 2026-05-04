import 'package:flutter/widgets.dart';

import '../theme/mosaic_theme.dart';
import '../tile/mosaic_tile_widget.dart';
import 'mosaic_dnd.dart';

/// Strict semantic grid that lets the user reorder its tiles by
/// long-pressing one and dragging it onto another. Drop on a tile and
/// the dragged tile takes its slot, shifting everything else right
/// (row-major).
///
/// Layout uses the same first-fit packing as [MosaicGrid]. Reorders
/// fire [onReorder] with `(oldIndex, newIndex)` so the consumer can
/// commit the new order to its source of truth.
///
/// Subset of [MosaicGrid]'s API: only [crossAxisCount] / [gutter] are
/// configurable. Everything else flows from tokens.
class MosaicReorderableGrid extends StatelessWidget {
  const MosaicReorderableGrid({
    super.key,
    required this.children,
    required this.onReorder,
    this.crossAxisCount,
    this.gutter,
    this.enabled = true,
    this.longPress = true,
  });

  final List<MosaicTileWidget> children;
  final void Function(int oldIndex, int newIndex) onReorder;
  final int? crossAxisCount;
  final double? gutter;

  /// Disables drag start. The grid still renders normally; only the
  /// reorder gesture is suppressed.
  final bool enabled;

  /// When true (default) tiles are draggable only after a long press —
  /// matching the launcher convention. Set false in tests or for
  /// always-immediate-drag surfaces.
  final bool longPress;

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
        if (placements.isEmpty) return const SizedBox.shrink();
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
              for (var i = 0; i < placements.length; i++)
                Positioned(
                  left: placements[i].col * (cell + g),
                  top: placements[i].row * (cell + g),
                  width: placements[i].tile.size.cols * cell +
                      (placements[i].tile.size.cols - 1) * g,
                  height: placements[i].tile.size.rows * cell +
                      (placements[i].tile.size.rows - 1) * g,
                  child: _ReorderSlot(
                    index: i,
                    tile: placements[i].tile,
                    onReorder: onReorder,
                    enabled: enabled,
                    longPress: longPress,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ReorderSlot extends StatelessWidget {
  const _ReorderSlot({
    required this.index,
    required this.tile,
    required this.onReorder,
    required this.enabled,
    required this.longPress,
  });

  final int index;
  final MosaicTileWidget tile;
  final void Function(int oldIndex, int newIndex) onReorder;
  final bool enabled;
  final bool longPress;

  @override
  Widget build(BuildContext context) {
    final draggable = MosaicDraggable<int>(
      data: index,
      enabled: enabled,
      longPress: longPress,
      child: tile,
    );
    if (!enabled) return draggable;
    return MosaicDropTarget<int>(
      onAccept: (from) {
        if (from == index) return;
        onReorder(from, index);
      },
      canAccept: (from) => from != index,
      child: draggable,
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
