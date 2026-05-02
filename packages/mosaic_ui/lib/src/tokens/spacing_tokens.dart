import 'package:flutter/foundation.dart';

@immutable
class MosaicSpacingTokens {
  const MosaicSpacingTokens({this.unit = 8.0});

  final double unit;

  double get xs => unit * 0.5;
  double get sm => unit;
  double get md => unit * 2;
  double get lg => unit * 3;
  double get xl => unit * 4;
  double get xxl => unit * 6;

  MosaicSpacingTokens copyWith({double? unit}) =>
      MosaicSpacingTokens(unit: unit ?? this.unit);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MosaicSpacingTokens && other.unit == unit);

  @override
  int get hashCode => unit.hashCode;
}
