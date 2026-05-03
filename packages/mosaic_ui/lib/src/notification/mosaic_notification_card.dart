import 'package:flutter/widgets.dart';

import '../press/mosaic_press_feedback.dart';
import '../theme/mosaic_theme.dart';
import '../tokens/mosaic_tokens.dart';

/// What kind of notification this is. Drives the accent strip color
/// and default glyph.
enum MosaicNotificationKind { info, success, warning, error }

/// A surface-shaped notification with a colored leading strip, title,
/// optional body, optional dismiss affordance, and optional inline
/// action. Use it inline (top of a surface) or stack a few in a column
/// — Mosaic prefers visible notifications over toasts that disappear.
class MosaicNotificationCard extends StatelessWidget {
  const MosaicNotificationCard({
    super.key,
    required this.title,
    this.body,
    this.kind = MosaicNotificationKind.info,
    this.glyph,
    this.action,
    this.onDismiss,
  });

  final String title;
  final String? body;
  final MosaicNotificationKind kind;

  /// Optional glyph override. When null, a kind-appropriate default is
  /// used (`ⓘ`, `✓`, `⚠`, `!`).
  final String? glyph;

  /// Optional inline action — typically a [MosaicButton] in ghost mode.
  final Widget? action;

  /// When non-null, a dismiss `×` affordance appears on the right.
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    final accent = _kindAccent(tokens);
    final resolvedGlyph = glyph ?? _kindGlyph();
    return ClipRRect(
      borderRadius: BorderRadius.circular(tokens.radius.tile),
      child: Container(
        decoration: BoxDecoration(
          color: tokens.color.surface,
          border: Border.all(color: tokens.color.divider, width: 1),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: accent),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(tokens.spacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: tokens.spacing.xs / 2),
                        child: Text(
                          resolvedGlyph,
                          style: tokens.typography.title.copyWith(
                            color: accent,
                          ),
                        ),
                      ),
                      SizedBox(width: tokens.spacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              style: tokens.typography.tileTitle.copyWith(
                                color: tokens.color.textPrimary,
                              ),
                            ),
                            if (body != null) ...[
                              SizedBox(height: tokens.spacing.xs),
                              Text(
                                body!,
                                style: tokens.typography.body.copyWith(
                                  color: tokens.color.textSecondary,
                                ),
                              ),
                            ],
                            if (action != null) ...[
                              SizedBox(height: tokens.spacing.sm),
                              action!,
                            ],
                          ],
                        ),
                      ),
                      if (onDismiss != null) ...[
                        SizedBox(width: tokens.spacing.sm),
                        MosaicPressFeedback(
                          onPressed: onDismiss,
                          semanticLabel: 'Dismiss',
                          child: Padding(
                            padding: EdgeInsets.all(tokens.spacing.xs),
                            child: Text(
                              '×',
                              style: tokens.typography.title.copyWith(
                                color: tokens.color.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _kindAccent(MosaicTokens tokens) => switch (kind) {
    MosaicNotificationKind.info => tokens.color.accent,
    MosaicNotificationKind.success => tokens.color.success,
    MosaicNotificationKind.warning => tokens.color.warning,
    MosaicNotificationKind.error => tokens.color.error,
  };

  String _kindGlyph() => switch (kind) {
    MosaicNotificationKind.info => 'ⓘ',
    MosaicNotificationKind.success => '✓',
    MosaicNotificationKind.warning => '⚠',
    MosaicNotificationKind.error => '!',
  };
}
