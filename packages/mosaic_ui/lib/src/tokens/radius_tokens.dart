import 'package:flutter/foundation.dart';

@immutable
class MosaicRadiusTokens {
  const MosaicRadiusTokens({
    required this.tile,
    required this.panel,
    required this.pill,
    required this.input,
  });

  final double tile;
  final double panel;
  final double pill;
  final double input;

  MosaicRadiusTokens copyWith({
    double? tile,
    double? panel,
    double? pill,
    double? input,
  }) {
    return MosaicRadiusTokens(
      tile: tile ?? this.tile,
      panel: panel ?? this.panel,
      pill: pill ?? this.pill,
      input: input ?? this.input,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MosaicRadiusTokens &&
        other.tile == tile &&
        other.panel == panel &&
        other.pill == pill &&
        other.input == input;
  }

  @override
  int get hashCode => Object.hash(tile, panel, pill, input);
}
