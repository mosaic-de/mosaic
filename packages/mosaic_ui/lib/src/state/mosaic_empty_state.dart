import 'package:flutter/widgets.dart';

import '../button/mosaic_button.dart';
import '../theme/mosaic_theme.dart';

/// Centered empty-state placeholder. For when the source legitimately
/// returned nothing (no transactions yet, no saved cities, no matches).
///
/// Distinct from [MosaicErrorState] — this is not a failure, it's a
/// "you haven't done anything here yet" or "nothing matches your
/// filter" surface. Tone is calm, not alarming.
class MosaicEmptyState extends StatelessWidget {
  const MosaicEmptyState({
    super.key,
    required this.title,
    this.body,
    this.glyph,
    this.actionLabel,
    this.onAction,
  }) : assert(
         (actionLabel == null) == (onAction == null),
         'Provide both actionLabel and onAction, or neither.',
       );

  final String title;
  final String? body;

  /// A single-character glyph (use `MosaicIcon` characters or any
  /// supplied unicode). Rendered large and tinted secondary.
  final String? glyph;

  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    return Padding(
      padding: EdgeInsets.all(tokens.spacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (glyph != null) ...[
            Text(
              glyph!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 56,
                color: tokens.color.textSecondary,
                height: 1,
              ),
            ),
            SizedBox(height: tokens.spacing.md),
          ],
          Text(
            title,
            textAlign: TextAlign.center,
            style: tokens.typography.title.copyWith(
              color: tokens.color.textPrimary,
            ),
          ),
          if (body != null) ...[
            SizedBox(height: tokens.spacing.sm),
            Text(
              body!,
              textAlign: TextAlign.center,
              style: tokens.typography.body.copyWith(
                color: tokens.color.textSecondary,
              ),
            ),
          ],
          if (actionLabel != null) ...[
            SizedBox(height: tokens.spacing.lg),
            MosaicButton(
              label: actionLabel!,
              onPressed: onAction!,
              kind: MosaicButtonKind.secondary,
              expand: false,
            ),
          ],
        ],
      ),
    );
  }
}
