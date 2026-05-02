import 'package:flutter/widgets.dart';

import 'mosaic_tile_size.dart';

/// Marker interface for any widget that can be packed into a
/// [MosaicGrid]. Both [MosaicTile] and [MosaicLiveTile] implement it.
abstract class MosaicTileWidget extends Widget {
  const MosaicTileWidget({super.key});

  MosaicTileSize get size;
}
