import 'package:flutter/foundation.dart';

/// Grid configuration. Mosaic uses a strict semantic grid; tile sizes
/// (Small, Medium, Wide, Tall, Large, Hero) map to spans against
/// [columnsMobile] / [columnsTablet] / [columnsDesktop].
@immutable
class MosaicGridTokens {
  const MosaicGridTokens({
    this.columnsMobile = 4,
    this.columnsTablet = 6,
    this.columnsDesktop = 8,
    this.margin = 16.0,
    this.gutter = 8.0,
  });

  final int columnsMobile;
  final int columnsTablet;
  final int columnsDesktop;
  final double margin;
  final double gutter;

  MosaicGridTokens copyWith({
    int? columnsMobile,
    int? columnsTablet,
    int? columnsDesktop,
    double? margin,
    double? gutter,
  }) {
    return MosaicGridTokens(
      columnsMobile: columnsMobile ?? this.columnsMobile,
      columnsTablet: columnsTablet ?? this.columnsTablet,
      columnsDesktop: columnsDesktop ?? this.columnsDesktop,
      margin: margin ?? this.margin,
      gutter: gutter ?? this.gutter,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MosaicGridTokens &&
        other.columnsMobile == columnsMobile &&
        other.columnsTablet == columnsTablet &&
        other.columnsDesktop == columnsDesktop &&
        other.margin == margin &&
        other.gutter == gutter;
  }

  @override
  int get hashCode =>
      Object.hash(columnsMobile, columnsTablet, columnsDesktop, margin, gutter);
}
