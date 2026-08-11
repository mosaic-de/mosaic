import 'package:flutter/widgets.dart';

import '../theme/mosaic_theme.dart';
import '../tokens/mosaic_tokens.dart';

/// Avatar shape. Square is the Metro default. Circle is provided for
/// Modern-mode surfaces or where convention demands it.
enum MosaicAvatarShape { square, circle }

/// Avatar size token. Mapped to fixed pixel sizes so consumers don't
/// fiddle with raw widths.
enum MosaicAvatarSize { sm, md, lg, xl }

/// Token-driven avatar. Renders, in priority order:
/// 1. [child] (e.g. an [Image] or a [MosaicIcon]),
/// 2. [initials] derived from up to two characters of the supplied
///    [name],
/// 3. an empty placeholder using the muted surface tone.
///
/// Square is the default to align with the Metro tile language.
class MosaicAvatar extends StatelessWidget {
  const MosaicAvatar({
    super.key,
    this.name,
    this.child,
    this.size = MosaicAvatarSize.md,
    this.shape = MosaicAvatarShape.square,
    this.background,
    this.foreground,
  });

  /// Display name. Used to compute up-to-two-character initials when no
  /// [child] is provided. `John Simiyu` → `JS`, `cher` → `C`.
  final String? name;

  /// Custom content (e.g. an image). Wins over [name].
  final Widget? child;

  final MosaicAvatarSize size;
  final MosaicAvatarShape shape;

  /// Override background. Defaults to the active surface token.
  final Color? background;

  /// Override foreground (text color). Defaults to primary text token.
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    final px = _pixelSize(size);
    final bg = background ?? tokens.color.surfaceActive;
    final fg = foreground ?? tokens.color.textPrimary;

    Widget body;
    if (child != null) {
      body = child!;
    } else if (name != null && name!.trim().isNotEmpty) {
      body = Text(_initials(name!), style: _initialsStyle(tokens, size, fg));
    } else {
      body = const SizedBox.shrink();
    }

    final radius = shape == MosaicAvatarShape.circle
        ? BorderRadius.circular(px / 2)
        : BorderRadius.circular(tokens.radius.tile.toDouble());

    return ClipRRect(
      borderRadius: radius,
      child: Container(
        width: px,
        height: px,
        alignment: Alignment.center,
        color: bg,
        child: body,
      ),
    );
  }

  static String _initials(String raw) {
    final parts = raw
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) {
      return parts.first.characters.first.toUpperCase();
    }
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  static double _pixelSize(MosaicAvatarSize s) => switch (s) {
    MosaicAvatarSize.sm => 24,
    MosaicAvatarSize.md => 36,
    MosaicAvatarSize.lg => 48,
    MosaicAvatarSize.xl => 72,
  };

  static TextStyle _initialsStyle(
    MosaicTokens tokens,
    MosaicAvatarSize size,
    Color fg,
  ) {
    final base = switch (size) {
      MosaicAvatarSize.sm => tokens.typography.caption,
      MosaicAvatarSize.md => tokens.typography.tileTitle,
      MosaicAvatarSize.lg => tokens.typography.title,
      MosaicAvatarSize.xl => tokens.typography.headline,
    };
    return base.copyWith(color: fg, height: 1, fontWeight: FontWeight.w500);
  }
}
