import 'package:flutter/widgets.dart';

import '../button/mosaic_button.dart';
import '../theme/mosaic_theme.dart';

/// Centered failure surface. Use when a fetch produced [DataError] and
/// there is no [lastKnown] value to keep on screen.
///
/// Distinct from [MosaicEmptyState]: this surface acknowledges
/// something went wrong and offers a retry. The error color tints the
/// glyph, but the body text stays primary so the message is readable.
class MosaicErrorState extends StatelessWidget {
  const MosaicErrorState({
    super.key,
    this.title = 'Something went wrong',
    this.body,
    this.glyph = '!',
    this.retryLabel = 'Retry',
    this.onRetry,
  });

  final String title;
  final String? body;
  final String glyph;
  final String retryLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    return Padding(
      padding: EdgeInsets.all(tokens.spacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            glyph,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 56,
              color: tokens.color.error,
              height: 1,
            ),
          ),
          SizedBox(height: tokens.spacing.md),
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
          if (onRetry != null) ...[
            SizedBox(height: tokens.spacing.lg),
            MosaicButton(
              label: retryLabel,
              onPressed: onRetry!,
              kind: MosaicButtonKind.secondary,
              expand: false,
            ),
          ],
        ],
      ),
    );
  }
}
