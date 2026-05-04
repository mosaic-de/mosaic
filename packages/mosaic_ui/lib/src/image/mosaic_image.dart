import 'dart:typed_data';

import 'package:flutter/widgets.dart';

import '../skeleton/mosaic_skeleton.dart';
import '../theme/mosaic_theme.dart';

/// Token-driven image with loading and error fallbacks. Pass either a
/// [url] (network) or [bytes] (in-memory) — exactly one. While the
/// image is fetching the widget shows a [MosaicSkeleton] of the same
/// size; on error it shows a muted surface with a subtle "?" glyph.
///
/// Use [MosaicAvatar] when you want initials fallback for a
/// profile-photo-shaped slot; use this one for anything else.
class MosaicImage extends StatelessWidget {
  const MosaicImage.network(
    String this.url, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.semanticLabel,
  }) : bytes = null;

  const MosaicImage.memory(
    Uint8List this.bytes, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.semanticLabel,
  }) : url = null;

  final String? url;
  final Uint8List? bytes;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    final radius = borderRadius ??
        BorderRadius.circular(tokens.radius.tile.toDouble());
    final body = bytes != null
        ? Image.memory(
            bytes!,
            width: width,
            height: height,
            fit: fit,
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) => _ErrorBox(
              width: width,
              height: height,
              radius: radius,
            ),
          )
        : Image.network(
            url!,
            width: width,
            height: height,
            fit: fit,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return MosaicSkeleton(
                width: width,
                height: height,
                radius: radius.topLeft.x,
              );
            },
            errorBuilder: (_, __, ___) => _ErrorBox(
              width: width,
              height: height,
              radius: radius,
            ),
          );
    return Semantics(
      label: semanticLabel,
      image: true,
      child: ClipRRect(borderRadius: radius, child: body),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({this.width, this.height, required this.radius});

  final double? width;
  final double? height;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: tokens.color.surfaceMuted,
        borderRadius: radius,
      ),
      alignment: Alignment.center,
      child: Text(
        '?',
        style: tokens.typography.title.copyWith(
          color: tokens.color.textSecondary,
          height: 1,
        ),
      ),
    );
  }
}
