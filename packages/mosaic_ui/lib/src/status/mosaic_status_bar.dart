import 'package:flutter/widgets.dart';

import '../theme/mosaic_theme.dart';

/// Shell identity strip that pins the app name (and optional caption)
/// to the top of a surface. Inspired by Metro's full-bleed wordmarks
/// — a single typographic line, no chrome.
///
/// Renders flush against [SafeArea] padding when used at the root of a
/// surface. Pair with a [MosaicPivot] below for the canonical shell.
class MosaicStatusBar extends StatelessWidget {
  const MosaicStatusBar({
    super.key,
    required this.title,
    this.caption,
    this.trailing,
    this.padding,
  });

  /// App or surface name. Rendered in the [headline] variant.
  final String title;

  /// Optional small caption beneath the title (e.g. logged-in user, an
  /// environment label, or a stale-data marker).
  final String? caption;

  /// Optional trailing slot — typically a small avatar, badge, or
  /// settings glyph. Kept tiny on purpose; this is not a command bar.
  final Widget? trailing;

  /// Override the default [tokens.spacing.lg] horizontal /
  /// [tokens.spacing.md] vertical padding.
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    final pad = padding ??
        EdgeInsets.symmetric(
          horizontal: tokens.spacing.lg,
          vertical: tokens.spacing.md,
        );
    return Padding(
      padding: pad,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tokens.typography.headline.copyWith(
                    color: tokens.color.textPrimary,
                    height: 1,
                  ),
                ),
                if (caption != null) ...[
                  SizedBox(height: tokens.spacing.xs),
                  Text(
                    caption!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tokens.typography.caption.copyWith(
                      color: tokens.color.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: tokens.spacing.md),
            trailing!,
          ],
        ],
      ),
    );
  }
}
