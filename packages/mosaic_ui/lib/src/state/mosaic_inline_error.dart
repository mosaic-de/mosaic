import 'package:flutter/widgets.dart';

import '../theme/mosaic_theme.dart';

/// Single-line in-flow error. Sits inline beneath an input or row when
/// a validation/parse error doesn't warrant a full surface takeover.
///
/// Renders a small bullet glyph and the message in the error tone. No
/// background, no border — keeps the surrounding form layout intact.
class MosaicInlineError extends StatelessWidget {
  const MosaicInlineError(this.message, {super.key, this.glyph = '!'});

  final String message;
  final String glyph;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          glyph,
          style: tokens.typography.caption.copyWith(
            color: tokens.color.error,
            fontWeight: FontWeight.w700,
            height: 1.3,
          ),
        ),
        SizedBox(width: tokens.spacing.xs),
        Flexible(
          child: Text(
            message,
            style: tokens.typography.caption.copyWith(
              color: tokens.color.error,
            ),
          ),
        ),
      ],
    );
  }
}
