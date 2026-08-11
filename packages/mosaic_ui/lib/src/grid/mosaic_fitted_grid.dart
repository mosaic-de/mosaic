import 'package:flutter/widgets.dart';

import '../theme/mosaic_theme.dart';
import '../tile/mosaic_tile_size.dart';
import '../tile/mosaic_tile_widget.dart';

/// Resolved geometry for a grid that must fill a fixed viewport exactly.
///
/// [MosaicGrid] and [MosaicReorderableGrid] grow downward and expect a
/// scroll parent: they derive a square cell from the width and let the
/// row count fall out of the content. That is the wrong model for a start
/// screen, where the viewport is the hard constraint and the content must
/// be made to fit it — a home surface that scrolls is a list wearing a
/// grid costume.
///
/// [MosaicGridFit] inverts the dependency. Width and height are given;
/// columns and rows are derived; the cell is then stretched so the grid
/// lands flush against all four edges with no remainder and no scroll.
@immutable
class MosaicGridFit {
  const MosaicGridFit({
    required this.cols,
    required this.rows,
    required this.cellWidth,
    required this.cellHeight,
    required this.gutter,
  });

  final int cols;
  final int rows;
  final double cellWidth;
  final double cellHeight;
  final double gutter;

  /// Total 1×1 slots on the surface. This is the home screen's hard
  /// capacity — the tile budget the launcher gets to spend.
  int get capacity => cols * rows;

  /// How far the cell departs from square, as a ratio ≥ 1. Exposed so
  /// callers can assert the grid still reads as a grid; anything past
  /// ~1.3 starts to look like stacked bars.
  double get aspectSkew =>
      cellWidth > cellHeight ? cellWidth / cellHeight : cellHeight / cellWidth;

  /// Pixel offset of a cell's top-left corner.
  Offset originOf(int col, int row) =>
      Offset(col * (cellWidth + gutter), row * (cellHeight + gutter));

  /// Pixel footprint of a `cols × rows` span, gutters included.
  Size sizeOf(int spanCols, int spanRows) => Size(
    spanCols * cellWidth + (spanCols - 1) * gutter,
    spanRows * cellHeight + (spanRows - 1) * gutter,
  );

  /// Derive columns and rows for [viewport].
  ///
  /// Columns come from [targetCell] — the ideal edge length of a 1×1 in
  /// logical pixels, defaulting to the ~78dp that reads as "tile", not
  /// "toolbar button". Rows are then whatever count keeps the cell
  /// closest to square in the remaining height. Both cell dimensions are
  /// finally stretched to consume the viewport exactly.
  static MosaicGridFit resolve({
    required Size viewport,
    required double gutter,
    double targetCell = 78,
    int minCols = 4,
    int maxCols = 12,
    int minRows = 3,
    int maxRows = 24,
  }) {
    assert(targetCell > 0, 'targetCell must be positive');
    final width = viewport.width;
    final height = viewport.height;

    final cols = (width / targetCell).round().clamp(minCols, maxCols);
    final cellWidth = (width - gutter * (cols - 1)) / cols;

    // Pick the row count whose natural cell height is nearest the cell
    // width, so the grid stays as square as the viewport allows.
    final rows = ((height + gutter) / (cellWidth + gutter)).round().clamp(
      minRows,
      maxRows,
    );
    final cellHeight = (height - gutter * (rows - 1)) / rows;

    return MosaicGridFit(
      cols: cols,
      rows: rows,
      cellWidth: cellWidth,
      cellHeight: cellHeight,
      gutter: gutter,
    );
  }
}

/// Where one tile landed on the fitted grid.
@immutable
class MosaicGridPlacement {
  const MosaicGridPlacement({
    required this.index,
    required this.size,
    required this.col,
    required this.row,
  });

  /// Index into the input list, so callers can map a placement back to
  /// their own model after demotion or reordering.
  final int index;

  /// The size actually used, which may be smaller than requested if the
  /// tile had to be demoted to fit.
  final MosaicTileSize size;
  final int col;
  final int row;
}

/// Outcome of packing a tile list into a bounded grid.
@immutable
class MosaicGridFitResult {
  const MosaicGridFitResult({
    required this.placements,
    required this.overflow,
    required this.holes,
    required this.demoted,
  });

  final List<MosaicGridPlacement> placements;

  /// Input indices that could not be placed at any size. The caller
  /// decides what this means — the launcher drops them from home and
  /// leaves them in the drawer.
  final List<int> overflow;

  /// Empty `(col, row)` cells left after packing. Fill these or the
  /// "fills the screen exactly" promise is only true of the bounding box.
  final List<({int col, int row})> holes;

  /// Input indices that were placed at a smaller size than requested.
  final List<int> demoted;

  bool get isExact => holes.isEmpty && overflow.isEmpty;
}

/// Sizes a tile may shrink to, largest first, when it will not fit as
/// requested. Ordered by cell count so a demotion always frees space.
const _demotionLadder = <MosaicTileSize, List<MosaicTileSize>>{
  MosaicTileSize.hero: [
    MosaicTileSize.large,
    MosaicTileSize.tall,
    MosaicTileSize.wide,
    MosaicTileSize.medium,
    MosaicTileSize.small,
  ],
  MosaicTileSize.large: [
    MosaicTileSize.tall,
    MosaicTileSize.wide,
    MosaicTileSize.medium,
    MosaicTileSize.small,
  ],
  MosaicTileSize.tall: [MosaicTileSize.medium, MosaicTileSize.small],
  MosaicTileSize.wide: [MosaicTileSize.medium, MosaicTileSize.small],
  MosaicTileSize.medium: [MosaicTileSize.small],
  MosaicTileSize.small: [],
};

/// Pack [sizes] into a fixed `cols × rows` canvas using row-major
/// first-fit.
///
/// When a tile will not fit at its requested size, it is demoted down
/// [_demotionLadder] rather than dropped — a 4×2 news tile becoming a 2×2
/// near the bottom edge is a better outcome than a hole plus a missing
/// app. Only when every size fails does the tile land in
/// [MosaicGridFitResult.overflow].
MosaicGridFitResult packToFit(
  List<MosaicTileSize> sizes, {
  required int cols,
  required int rows,
  bool allowDemotion = true,
  bool reserveLastCell = false,
}) {
  if (cols <= 0 || rows <= 0) {
    return const MosaicGridFitResult(
      placements: [],
      overflow: [],
      holes: [],
      demoted: [],
    );
  }

  final occupied = List<List<bool>>.generate(
    rows,
    (_) => List<bool>.filled(cols, false),
    growable: false,
  );
  final placements = <MosaicGridPlacement>[];
  final overflow = <int>[];
  final demoted = <int>[];

  // Claim the bottom-right cell before anything is placed. A caller that
  // needs a permanent affordance there — a launcher's "all apps" tile —
  // cannot get one by appending it to the list: the tail of a list is
  // exactly what overflows once the content exceeds capacity, so the one
  // tile that must never disappear would be the first to go.
  if (reserveLastCell) {
    occupied[rows - 1][cols - 1] = true;
  }

  bool fits(int row, int col, int spanCols, int spanRows) {
    if (col + spanCols > cols || row + spanRows > rows) return false;
    for (var r = row; r < row + spanRows; r++) {
      for (var c = col; c < col + spanCols; c++) {
        if (occupied[r][c]) return false;
      }
    }
    return true;
  }

  void mark(int row, int col, int spanCols, int spanRows) {
    for (var r = row; r < row + spanRows; r++) {
      for (var c = col; c < col + spanCols; c++) {
        occupied[r][c] = true;
      }
    }
  }

  /// First free slot for a span, or null when the canvas has no room.
  ({int col, int row})? firstFit(MosaicTileSize size) {
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c <= cols - size.cols; c++) {
        if (fits(r, c, size.cols, size.rows)) return (col: c, row: r);
      }
    }
    return null;
  }

  for (var i = 0; i < sizes.length; i++) {
    final requested = sizes[i];
    final candidates = <MosaicTileSize>[
      requested,
      if (allowDemotion) ..._demotionLadder[requested] ?? const [],
    ];

    var placed = false;
    for (final size in candidates) {
      final slot = firstFit(size);
      if (slot == null) continue;
      mark(slot.row, slot.col, size.cols, size.rows);
      placements.add(
        MosaicGridPlacement(index: i, size: size, col: slot.col, row: slot.row),
      );
      if (size != requested) demoted.add(i);
      placed = true;
      break;
    }
    if (!placed) overflow.add(i);
  }

  final holes = <({int col, int row})>[];
  for (var r = 0; r < rows; r++) {
    for (var c = 0; c < cols; c++) {
      if (!occupied[r][c]) holes.add((col: c, row: r));
    }
  }
  // The reserved cell is occupied for packing purposes but is not a hole
  // the caller should fill — its content is supplied separately.

  return MosaicGridFitResult(
    placements: placements,
    overflow: overflow,
    holes: holes,
    demoted: demoted,
  );
}

/// A non-scrolling grid that fills its box exactly.
///
/// Packs [children] into the viewport, demoting oversized tiles rather
/// than dropping them, and asks [holeBuilder] to fill any 1×1 gaps left
/// over so the surface has no ragged bottom edge. Children that cannot be
/// placed at any size are reported via [onOverflow] and not rendered.
class MosaicFittedGrid extends StatelessWidget {
  const MosaicFittedGrid({
    super.key,
    required this.children,
    this.gutter,
    this.targetCell = 78,
    this.holeBuilder,
    this.onOverflow,
    this.onFitResolved,
    this.slotBuilder,
    this.trailing,
  });

  final List<MosaicTileWidget> children;

  /// Pinned to the bottom-right 1×1 cell, which is withheld from packing.
  ///
  /// For an affordance that must always be reachable. Putting such a
  /// widget at the end of [children] does not work: the tail is the first
  /// thing to overflow when content exceeds capacity, so the one tile
  /// that must never vanish would be the one most likely to.
  final Widget? trailing;

  final double? gutter;

  /// Ideal edge length of a 1×1 cell, in logical pixels. Drives the
  /// column count.
  final double targetCell;

  /// Builds filler content for leftover 1×1 cells, in fill order. Return
  /// null to leave a gap empty.
  final Widget? Function(BuildContext context, int fillIndex)? holeBuilder;

  /// Called during layout with the indices that did not fit. Use it to
  /// reconcile persisted state — but do not call setState synchronously.
  final void Function(List<int> overflow)? onOverflow;

  /// Called during layout with the resolved geometry.
  final void Function(MosaicGridFit fit)? onFitResolved;

  /// Wraps each placed child, receiving its index in [children] and the
  /// size it was actually laid out at. Lets a launcher attach drag,
  /// press, and swap affordances without this widget knowing about them.
  final Widget Function(
    BuildContext context,
    int index,
    MosaicTileSize size,
    Widget child,
  )?
  slotBuilder;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    final g = gutter ?? tokens.grid.gutter;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedHeight || !constraints.hasBoundedWidth) {
          assert(
            false,
            'MosaicFittedGrid needs a bounded box — it sizes itself to the '
            'viewport by design. Do not place it inside a scroll view.',
          );
          return const SizedBox.shrink();
        }
        final viewport = Size(constraints.maxWidth, constraints.maxHeight);
        if (viewport.isEmpty) return const SizedBox.shrink();

        final fit = MosaicGridFit.resolve(
          viewport: viewport,
          gutter: g,
          targetCell: targetCell,
        );
        onFitResolved?.call(fit);

        final result = packToFit(
          [for (final child in children) child.size],
          cols: fit.cols,
          rows: fit.rows,
          reserveLastCell: trailing != null,
        );
        if (result.overflow.isNotEmpty) onOverflow?.call(result.overflow);

        final positioned = <Widget>[];

        if (trailing != null) {
          final origin = fit.originOf(fit.cols - 1, fit.rows - 1);
          final size = fit.sizeOf(1, 1);
          positioned.add(
            Positioned(
              left: origin.dx,
              top: origin.dy,
              width: size.width,
              height: size.height,
              child: trailing!,
            ),
          );
        }

        for (final placement in result.placements) {
          final origin = fit.originOf(placement.col, placement.row);
          final size = fit.sizeOf(placement.size.cols, placement.size.rows);
          final child = children[placement.index];
          positioned.add(
            Positioned(
              left: origin.dx,
              top: origin.dy,
              width: size.width,
              height: size.height,
              child:
                  slotBuilder?.call(
                    context,
                    placement.index,
                    placement.size,
                    child,
                  ) ??
                  child,
            ),
          );
        }

        if (holeBuilder != null) {
          for (var i = 0; i < result.holes.length; i++) {
            final hole = result.holes[i];
            final filler = holeBuilder!(context, i);
            if (filler == null) continue;
            final origin = fit.originOf(hole.col, hole.row);
            final size = fit.sizeOf(1, 1);
            positioned.add(
              Positioned(
                left: origin.dx,
                top: origin.dy,
                width: size.width,
                height: size.height,
                child: filler,
              ),
            );
          }
        }

        return SizedBox(
          width: viewport.width,
          height: viewport.height,
          child: Stack(
            alignment: Alignment.topLeft,
            clipBehavior: Clip.hardEdge,
            children: positioned,
          ),
        );
      },
    );
  }
}
