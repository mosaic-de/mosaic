// prefer_initializing_formals fires on the two constructors below and is
// wrong about them. `rows:` and `itemCount:` are the public parameter
// names; the fields behind them are private because which of the two is
// populated is an implementation detail of the named constructors. The
// lint's fix — `this._rows` — is not expressible: Dart forbids a private
// named parameter, so callers could not pass it at all.
// ignore_for_file: prefer_initializing_formals

import 'package:flutter/widgets.dart';

import '../press/mosaic_press_feedback.dart';
import '../theme/mosaic_theme.dart';

/// Vertical list of [MosaicListRow] entries with token-driven dividers.
///
/// Use [MosaicList.builder] for large or paginated lists where the rows
/// should be built lazily.
class MosaicList extends StatelessWidget {
  const MosaicList({
    super.key,
    required List<MosaicListRow> rows,
    this.padding,
    this.divider = true,
    this.shrinkWrap = false,
    this.physics,
  }) : _rows = rows,
       _itemCount = null,
       _builder = null;

  const MosaicList.builder({
    super.key,
    required int itemCount,
    required MosaicListRow Function(BuildContext, int) builder,
    this.padding,
    this.divider = true,
    this.shrinkWrap = false,
    this.physics,
  }) : _itemCount = itemCount,
       _builder = builder,
       _rows = null;

  final List<MosaicListRow>? _rows;
  final int? _itemCount;
  final MosaicListRow Function(BuildContext, int)? _builder;
  final EdgeInsetsGeometry? padding;
  final bool divider;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    final count = _itemCount ?? _rows!.length;
    return ListView.separated(
      padding: padding ?? EdgeInsets.symmetric(vertical: tokens.spacing.sm),
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: count,
      separatorBuilder: divider
          ? (_, _) => Padding(
              padding: EdgeInsets.symmetric(vertical: tokens.spacing.xs),
              child: Container(height: 1, color: tokens.color.divider),
            )
          : (_, _) => SizedBox(height: tokens.spacing.xs),
      itemBuilder: (context, i) =>
          _builder != null ? _builder(context, i) : _rows![i],
    );
  }
}

/// One row in a [MosaicList].
///
/// Composes leading + (title / subtitle) + trailing in a single line.
/// If [onPressed] or [onLongPress] is non-null the row gains
/// [MosaicPressFeedback] automatically.
class MosaicListRow extends StatelessWidget {
  const MosaicListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onPressed,
    this.onLongPress,
    this.enabled = true,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final bool enabled;

  bool get _isInteractive =>
      enabled && (onPressed != null || onLongPress != null);

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    final row = Padding(
      padding: EdgeInsets.symmetric(vertical: tokens.spacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leading != null) ...[
            leading!,
            SizedBox(width: tokens.spacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: tokens.typography.body.copyWith(
                    color: tokens.color.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: tokens.typography.caption.copyWith(
                      color: tokens.color.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
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

    if (!_isInteractive) return row;
    return MosaicPressFeedback(
      onPressed: onPressed,
      onLongPress: onLongPress,
      enabled: enabled,
      semanticLabel: title,
      child: row,
    );
  }
}
