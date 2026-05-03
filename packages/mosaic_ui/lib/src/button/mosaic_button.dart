import 'package:flutter/widgets.dart';

import '../press/mosaic_press_feedback.dart';
import '../theme/mosaic_theme.dart';
import '../tokens/mosaic_tokens.dart';

/// What kind of role this button plays.
///
/// `primary` — the principal action on a surface (Send, Pay, Confirm).
/// `secondary` — supporting action that should not dominate.
/// `ghost` — text-only action; visually quiet, used in dense rows.
enum MosaicButtonKind { primary, secondary, ghost }

/// Token-driven button. Replaces the hand-rolled "primary button" both
/// demos used to define inline. For text-only actions reach for ghost;
/// for the principal verb on a surface use primary.
class MosaicButton extends StatelessWidget {
  const MosaicButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.kind = MosaicButtonKind.primary,
    this.glyph,
    this.enabled = true,
    this.expand = true,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback onPressed;
  final MosaicButtonKind kind;
  final String? glyph;
  final bool enabled;

  /// When true, the button stretches to fill the available width. When
  /// false, it shrinks to fit its content. Defaults to true because
  /// most layouts want a confirm-style full-width affordance; flip it
  /// for inline rows.
  final bool expand;

  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    final colors = _kindColors(tokens);
    final body = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.md,
        vertical: tokens.spacing.sm,
      ),
      child: DefaultTextStyle.merge(
        style: tokens.typography.tileTitle.copyWith(
          color: colors.fg,
          fontWeight: FontWeight.w500,
          height: 1,
        ),
        child: Row(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (glyph != null) ...[
              Text(glyph!),
              SizedBox(width: tokens.spacing.xs),
            ],
            Text(label),
          ],
        ),
      ),
    );
    return MosaicPressFeedback(
      onPressed: onPressed,
      enabled: enabled,
      semanticLabel: semanticLabel ?? label,
      child: Container(
        decoration: BoxDecoration(
          color: colors.bg,
          borderRadius: BorderRadius.circular(tokens.radius.input),
          border: colors.border != null
              ? Border.all(color: colors.border!, width: 1)
              : null,
        ),
        child: body,
      ),
    );
  }

  _KindColors _kindColors(MosaicTokens tokens) {
    return switch (kind) {
      MosaicButtonKind.primary => _KindColors(
        bg: tokens.color.accent,
        fg: tokens.color.textInverse,
      ),
      MosaicButtonKind.secondary => _KindColors(
        bg: tokens.color.surfaceMuted,
        fg: tokens.color.textPrimary,
        border: tokens.color.divider,
      ),
      MosaicButtonKind.ghost => _KindColors(
        bg: const Color(0x00000000),
        fg: tokens.color.textPrimary,
      ),
    };
  }
}

class _KindColors {
  const _KindColors({required this.bg, required this.fg, this.border});
  final Color bg;
  final Color fg;
  final Color? border;
}
