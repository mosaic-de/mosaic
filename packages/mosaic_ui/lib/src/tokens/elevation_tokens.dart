import 'package:flutter/foundation.dart';

/// Elevation in logical pixels. Metro mode is uniformly zero.
/// Modern mode uses subtle values; Mosaic never uses heavy shadows.
@immutable
class MosaicElevationTokens {
  const MosaicElevationTokens({
    required this.tile,
    required this.panel,
    required this.overlay,
  });

  final double tile;
  final double panel;
  final double overlay;

  MosaicElevationTokens copyWith({
    double? tile,
    double? panel,
    double? overlay,
  }) {
    return MosaicElevationTokens(
      tile: tile ?? this.tile,
      panel: panel ?? this.panel,
      overlay: overlay ?? this.overlay,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MosaicElevationTokens &&
        other.tile == tile &&
        other.panel == panel &&
        other.overlay == overlay;
  }

  @override
  int get hashCode => Object.hash(tile, panel, overlay);
}
