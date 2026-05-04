import 'package:flutter/widgets.dart';

import '../theme/mosaic_theme.dart';
import 'mosaic_tile.dart';
import 'mosaic_tile_size.dart';
import 'mosaic_tile_widget.dart';

/// Tile that previews a small grid of inner widgets and opens a panel
/// (or any [onOpen] callback) when tapped. Designed for grouping
/// related app/launcher tiles into a folder, but works for any
/// "here's a summary of N things" surface.
///
/// The folder shows up to four previews in a 2×2 mini-grid. The
/// [count] (if larger than the previews shown) is displayed as a
/// "+N" overlay in the bottom-right.
class MosaicFolderTile extends StatelessWidget implements MosaicTileWidget {
  const MosaicFolderTile({
    super.key,
    required this.label,
    required this.previews,
    required this.size,
    required this.onOpen,
    this.count,
    this.onLongPress,
  })  : assert(previews.length <= 4,
            'MosaicFolderTile shows at most 4 previews; pass count for the total.');

  final String label;
  final List<Widget> previews;

  /// Total member count if larger than the preview list. Used to show
  /// the "+N" overlay. When null, no overlay appears.
  final int? count;

  @override
  final MosaicTileSize size;
  final VoidCallback onOpen;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    final extra = (count ?? 0) - previews.length;
    return MosaicTile(
      size: size,
      onPressed: onOpen,
      onLongPress: onLongPress,
      semanticLabel: 'Folder: $label',
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(child: _PreviewGrid(previews: previews)),
                  if (extra > 0)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: tokens.spacing.xs,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: tokens.color.accent,
                          borderRadius: BorderRadius.circular(
                            tokens.radius.pill.toDouble(),
                          ),
                        ),
                        child: Text(
                          '+$extra',
                          style: tokens.typography.caption.copyWith(
                            color: tokens.color.textInverse,
                            fontWeight: FontWeight.w600,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: tokens.spacing.xs),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tokens.typography.tileTitle.copyWith(
                color: tokens.color.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewGrid extends StatelessWidget {
  const _PreviewGrid({required this.previews});

  final List<Widget> previews;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    final placeholders = List<Widget>.generate(
      4 - previews.length,
      (_) => DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.color.surfaceMuted,
          borderRadius: BorderRadius.circular(tokens.radius.tile.toDouble()),
        ),
      ),
    );
    final cells = <Widget>[...previews, ...placeholders];
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: tokens.spacing.xs,
      crossAxisSpacing: tokens.spacing.xs,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        for (final cell in cells)
          ClipRRect(
            borderRadius: BorderRadius.circular(tokens.radius.tile.toDouble()),
            child: cell,
          ),
      ],
    );
  }
}
