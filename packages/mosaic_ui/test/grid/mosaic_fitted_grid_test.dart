import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

void main() {
  group('MosaicGridFit.resolve', () {
    test('fills the viewport exactly on both axes', () {
      const viewport = Size(412, 780);
      final fit = MosaicGridFit.resolve(viewport: viewport, gutter: 2);

      final spannedWidth =
          fit.cols * fit.cellWidth + (fit.cols - 1) * fit.gutter;
      final spannedHeight =
          fit.rows * fit.cellHeight + (fit.rows - 1) * fit.gutter;

      expect(spannedWidth, closeTo(viewport.width, 0.001));
      expect(spannedHeight, closeTo(viewport.height, 0.001));
    });

    test('keeps cells close to square', () {
      final fit = MosaicGridFit.resolve(
        viewport: const Size(412, 780),
        gutter: 2,
      );
      expect(fit.aspectSkew, lessThan(1.3));
    });

    test('picks 5 columns on a Pixel-class 412dp width', () {
      final fit = MosaicGridFit.resolve(
        viewport: const Size(412, 780),
        gutter: 2,
      );
      expect(fit.cols, 5);
    });

    test('clamps columns on very small and very wide viewports', () {
      final tiny = MosaicGridFit.resolve(
        viewport: const Size(200, 400),
        gutter: 2,
      );
      final huge = MosaicGridFit.resolve(
        viewport: const Size(3000, 1600),
        gutter: 2,
      );
      expect(tiny.cols, 4);
      expect(huge.cols, 12);
    });

    test('originOf and sizeOf agree with the resolved geometry', () {
      final fit = MosaicGridFit.resolve(
        viewport: const Size(412, 780),
        gutter: 4,
      );
      expect(fit.originOf(0, 0), Offset.zero);
      expect(
        fit.originOf(2, 3),
        Offset(2 * (fit.cellWidth + 4), 3 * (fit.cellHeight + 4)),
      );
      expect(fit.sizeOf(1, 1), Size(fit.cellWidth, fit.cellHeight));
      expect(fit.sizeOf(2, 2).width, fit.cellWidth * 2 + 4);
    });
  });

  group('packToFit', () {
    test('places tiles row-major, first-fit', () {
      final result = packToFit(
        const [
          MosaicTileSize.medium,
          MosaicTileSize.small,
          MosaicTileSize.small,
        ],
        cols: 4,
        rows: 4,
      );
      expect(result.placements[0].col, 0);
      expect(result.placements[0].row, 0);
      expect(result.placements[1].col, 2);
      expect(result.placements[1].row, 0);
      expect(result.placements[2].col, 3);
      expect(result.placements[2].row, 0);
    });

    test('never places a tile outside the row bound', () {
      final result = packToFit(
        List<MosaicTileSize>.filled(40, MosaicTileSize.medium),
        cols: 4,
        rows: 4,
      );
      for (final p in result.placements) {
        expect(p.col + p.size.cols, lessThanOrEqualTo(4));
        expect(p.row + p.size.rows, lessThanOrEqualTo(4));
      }
    });

    test('demotes an oversized tile rather than dropping it', () {
      // A 4x2 wide tile cannot fit in a 3-column grid at full size, but a
      // demoted 2x2 can.
      final result = packToFit(const [MosaicTileSize.wide], cols: 3, rows: 4);
      expect(result.overflow, isEmpty);
      expect(result.demoted, [0]);
      expect(result.placements.single.size, MosaicTileSize.medium);
    });

    test('reports overflow only when no size fits', () {
      final result = packToFit(
        const [
          MosaicTileSize.small,
          MosaicTileSize.small,
          MosaicTileSize.small,
        ],
        cols: 1,
        rows: 2,
      );
      expect(result.placements, hasLength(2));
      expect(result.overflow, [2]);
    });

    test('demotion can be disabled', () {
      final result = packToFit(
        const [MosaicTileSize.wide],
        cols: 3,
        rows: 4,
        allowDemotion: false,
      );
      expect(result.placements, isEmpty);
      expect(result.overflow, [0]);
    });

    test('reports every leftover cell as a hole', () {
      final result = packToFit(const [MosaicTileSize.medium], cols: 4, rows: 2);
      // 4x2 = 8 cells, a medium takes 4, so 4 remain.
      expect(result.holes, hasLength(4));
      expect(result.isExact, isFalse);
    });

    test('isExact when tiles tile the canvas perfectly', () {
      final result = packToFit(
        const [MosaicTileSize.medium, MosaicTileSize.medium],
        cols: 4,
        rows: 2,
      );
      expect(result.holes, isEmpty);
      expect(result.overflow, isEmpty);
      expect(result.isExact, isTrue);
    });

    test('tiles never overlap', () {
      final result = packToFit(
        const [
          MosaicTileSize.wide,
          MosaicTileSize.medium,
          MosaicTileSize.small,
          MosaicTileSize.tall,
          MosaicTileSize.medium,
          MosaicTileSize.small,
        ],
        cols: 6,
        rows: 8,
      );
      final seen = <String>{};
      for (final p in result.placements) {
        for (var r = p.row; r < p.row + p.size.rows; r++) {
          for (var c = p.col; c < p.col + p.size.cols; c++) {
            expect(seen.add('$c,$r'), isTrue, reason: 'overlap at $c,$r');
          }
        }
      }
      // Every cell is either covered or reported as a hole.
      expect(seen.length + result.holes.length, 6 * 8);
    });

    test('reserveLastCell withholds the bottom-right cell', () {
      final result = packToFit(
        List<MosaicTileSize>.filled(16, MosaicTileSize.small),
        cols: 4,
        rows: 4,
        reserveLastCell: true,
      );
      // 16 cells, one reserved, so exactly one tile is turned away.
      expect(result.placements, hasLength(15));
      expect(result.overflow, [15]);
      for (final p in result.placements) {
        expect(
          p.col == 3 && p.row == 3,
          isFalse,
          reason: 'nothing may be placed in the reserved cell',
        );
      }
    });

    test('reserved cell is not reported as a fillable hole', () {
      final result = packToFit(
        const [],
        cols: 3,
        rows: 3,
        reserveLastCell: true,
      );
      expect(result.holes, hasLength(8));
      expect(result.holes.any((h) => h.col == 2 && h.row == 2), isFalse);
    });

    test('a reserved trailing cell survives heavy overflow', () {
      // The behaviour this exists for: the launcher's "all apps" tile
      // was appended last and therefore was the first thing dropped
      // once the seed exceeded the screen, leaving no route to the
      // drawer at all.
      final result = packToFit(
        List<MosaicTileSize>.filled(200, MosaicTileSize.medium),
        cols: 4,
        rows: 4,
        reserveLastCell: true,
      );
      expect(result.overflow, isNotEmpty);
      for (final p in result.placements) {
        for (var r = p.row; r < p.row + p.size.rows; r++) {
          for (var c = p.col; c < p.col + p.size.cols; c++) {
            expect(c == 3 && r == 3, isFalse);
          }
        }
      }
    });

    test('degenerate canvases return an empty result', () {
      final result = packToFit(const [MosaicTileSize.small], cols: 0, rows: 0);
      expect(result.placements, isEmpty);
      expect(result.holes, isEmpty);
    });
  });

  group('MosaicFittedGrid', () {
    testWidgets('renders inside the viewport without scrolling', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(412, 780));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      MosaicGridFit? resolved;
      await tester.pumpWidget(
        MosaicTheme.test(
          child: MediaQuery(
            data: const MediaQueryData(size: Size(412, 780)),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: MosaicFittedGrid(
                gutter: 2,
                onFitResolved: (fit) => resolved = fit,
                children: [
                  for (var i = 0; i < 12; i++)
                    _TestTile(
                      size: i.isEven
                          ? MosaicTileSize.small
                          : MosaicTileSize.medium,
                    ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(resolved, isNotNull);
      expect(find.byType(Scrollable), findsNothing);

      final box = tester.getSize(find.byType(MosaicFittedGrid));
      expect(box.height, closeTo(780, 0.5));
      expect(box.width, closeTo(412, 0.5));
    });

    testWidgets('trailing occupies the bottom-right cell', (tester) async {
      await tester.binding.setSurfaceSize(const Size(412, 780));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      MosaicGridFit? fit;
      await tester.pumpWidget(
        MosaicTheme.test(
          child: MediaQuery(
            data: const MediaQueryData(size: Size(412, 780)),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: MosaicFittedGrid(
                gutter: 2,
                onFitResolved: (f) => fit = f,
                trailing: const ColoredBox(
                  key: ValueKey('trailing'),
                  color: Color(0xFFAA0000),
                ),
                // Far more content than the viewport can hold, so the
                // trailing widget would be long gone if it were packed.
                children: [
                  for (var i = 0; i < 400; i++)
                    const _TestTile(size: MosaicTileSize.medium),
                ],
              ),
            ),
          ),
        ),
      );

      final trailing = find.byKey(const ValueKey('trailing'));
      expect(trailing, findsOneWidget);

      final box = tester.getRect(trailing);
      final expected = fit!.originOf(fit!.cols - 1, fit!.rows - 1);
      expect(box.left, closeTo(expected.dx, 0.5));
      expect(box.top, closeTo(expected.dy, 0.5));
    });

    testWidgets('fills leftover cells via holeBuilder', (tester) async {
      await tester.binding.setSurfaceSize(const Size(412, 780));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      var fills = 0;
      await tester.pumpWidget(
        MosaicTheme.test(
          child: MediaQuery(
            data: const MediaQueryData(size: Size(412, 780)),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: MosaicFittedGrid(
                gutter: 2,
                holeBuilder: (context, i) {
                  fills++;
                  return const SizedBox.shrink();
                },
                children: const [_TestTile(size: MosaicTileSize.medium)],
              ),
            ),
          ),
        ),
      );

      // One 2x2 on a 5-col grid leaves the rest of the surface empty.
      expect(fills, greaterThan(0));
    });
  });
}

class _TestTile extends StatelessWidget implements MosaicTileWidget {
  const _TestTile({required this.size});

  @override
  final MosaicTileSize size;

  @override
  Widget build(BuildContext context) =>
      const ColoredBox(color: Color(0xFF336699));
}
