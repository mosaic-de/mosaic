import 'package:flutter/widgets.dart';

import '../theme/mosaic_theme.dart';
import '../tokens/mosaic_tokens.dart';

/// Typography variant. Maps to a [TextStyle] in
/// [MosaicTypographyTokens].
enum MosaicTextVariant {
  display,
  headline,
  title,
  body,
  caption,
  metric,
  tileTitle,
  tileSubtitle,
}

/// Color role. Resolves to a token color so consumers don't reach for
/// raw values.
enum MosaicTextTone {
  primary,
  secondary,
  accent,
  error,
  success,
  warning,
  inverse,
}

/// Token-driven [Text]. The library's preferred way to render any
/// piece of copy — wraps Flutter's [Text] with the typography variant
/// and a tone instead of consumers writing
/// `style: tokens.typography.body.copyWith(color: tokens.color.textPrimary)`
/// at every call site.
class MosaicText extends StatelessWidget {
  const MosaicText(
    this.text, {
    super.key,
    this.variant = MosaicTextVariant.body,
    this.tone = MosaicTextTone.primary,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.weight,
    this.height,
  });

  /// Convenience constructors for the common variants. They all defer
  /// to the main constructor — pass `tone` or `color` to override the
  /// default `primary` tone.
  const MosaicText.display(
    this.text, {
    super.key,
    this.tone = MosaicTextTone.primary,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.weight,
    this.height,
  }) : variant = MosaicTextVariant.display;
  const MosaicText.headline(
    this.text, {
    super.key,
    this.tone = MosaicTextTone.primary,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.weight,
    this.height,
  }) : variant = MosaicTextVariant.headline;
  const MosaicText.title(
    this.text, {
    super.key,
    this.tone = MosaicTextTone.primary,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.weight,
    this.height,
  }) : variant = MosaicTextVariant.title;
  const MosaicText.body(
    this.text, {
    super.key,
    this.tone = MosaicTextTone.primary,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.weight,
    this.height,
  }) : variant = MosaicTextVariant.body;
  const MosaicText.caption(
    this.text, {
    super.key,
    this.tone = MosaicTextTone.secondary,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.weight,
    this.height,
  }) : variant = MosaicTextVariant.caption;
  const MosaicText.metric(
    this.text, {
    super.key,
    this.tone = MosaicTextTone.primary,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.weight,
    this.height,
  }) : variant = MosaicTextVariant.metric;
  const MosaicText.tileTitle(
    this.text, {
    super.key,
    this.tone = MosaicTextTone.primary,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.weight,
    this.height,
  }) : variant = MosaicTextVariant.tileTitle;
  const MosaicText.tileSubtitle(
    this.text, {
    super.key,
    this.tone = MosaicTextTone.secondary,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.weight,
    this.height,
  }) : variant = MosaicTextVariant.tileSubtitle;

  final String text;
  final MosaicTextVariant variant;
  final MosaicTextTone tone;

  /// Hard color override. Beats [tone] when set.
  final Color? color;

  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;
  final FontWeight? weight;

  /// Line-height multiplier override. Pass `1` for tight rows where
  /// the default 1.2-ish leading would push glyphs visually low.
  final double? height;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    final base = _styleFor(tokens, variant);
    final resolvedColor = color ?? _toneColor(tokens, tone);
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      style: base.copyWith(
        color: resolvedColor,
        fontWeight: weight,
        height: height,
      ),
    );
  }

  static TextStyle _styleFor(MosaicTokens tokens, MosaicTextVariant v) =>
      switch (v) {
        MosaicTextVariant.display => tokens.typography.display,
        MosaicTextVariant.headline => tokens.typography.headline,
        MosaicTextVariant.title => tokens.typography.title,
        MosaicTextVariant.body => tokens.typography.body,
        MosaicTextVariant.caption => tokens.typography.caption,
        MosaicTextVariant.metric => tokens.typography.metric,
        MosaicTextVariant.tileTitle => tokens.typography.tileTitle,
        MosaicTextVariant.tileSubtitle => tokens.typography.tileSubtitle,
      };

  static Color _toneColor(MosaicTokens tokens, MosaicTextTone tone) =>
      switch (tone) {
        MosaicTextTone.primary => tokens.color.textPrimary,
        MosaicTextTone.secondary => tokens.color.textSecondary,
        MosaicTextTone.accent => tokens.color.accent,
        MosaicTextTone.error => tokens.color.error,
        MosaicTextTone.success => tokens.color.success,
        MosaicTextTone.warning => tokens.color.warning,
        MosaicTextTone.inverse => tokens.color.textInverse,
      };
}
