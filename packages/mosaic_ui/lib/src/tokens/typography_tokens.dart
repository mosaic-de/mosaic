import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Typography tokens are color-free. Components compose them with
/// [MosaicColorTokens] when rendering, keeping color and type orthogonal.
@immutable
class MosaicTypographyTokens {
  const MosaicTypographyTokens({
    required this.display,
    required this.headline,
    required this.title,
    required this.body,
    required this.caption,
    required this.metric,
    required this.tileTitle,
    required this.tileSubtitle,
  });

  final TextStyle display;
  final TextStyle headline;
  final TextStyle title;
  final TextStyle body;
  final TextStyle caption;
  final TextStyle metric;
  final TextStyle tileTitle;
  final TextStyle tileSubtitle;

  MosaicTypographyTokens copyWith({
    TextStyle? display,
    TextStyle? headline,
    TextStyle? title,
    TextStyle? body,
    TextStyle? caption,
    TextStyle? metric,
    TextStyle? tileTitle,
    TextStyle? tileSubtitle,
  }) {
    return MosaicTypographyTokens(
      display: display ?? this.display,
      headline: headline ?? this.headline,
      title: title ?? this.title,
      body: body ?? this.body,
      caption: caption ?? this.caption,
      metric: metric ?? this.metric,
      tileTitle: tileTitle ?? this.tileTitle,
      tileSubtitle: tileSubtitle ?? this.tileSubtitle,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MosaicTypographyTokens &&
        other.display == display &&
        other.headline == headline &&
        other.title == title &&
        other.body == body &&
        other.caption == caption &&
        other.metric == metric &&
        other.tileTitle == tileTitle &&
        other.tileSubtitle == tileSubtitle;
  }

  @override
  int get hashCode => Object.hash(
    display,
    headline,
    title,
    body,
    caption,
    metric,
    tileTitle,
    tileSubtitle,
  );
}
