import 'package:flutter/widgets.dart';

import '../theme/mosaic_theme.dart';

/// Hairline separator. Resolves to [MosaicColorTokens.divider] and
/// renders at the design-system's standard 1 logical pixel thickness
/// regardless of mode. Use [MosaicDivider.vertical] inside rows.
///
/// Optional [indent] / [endIndent] inset the line from each end so it
/// aligns with surrounding content (e.g. start at the same x as a list
/// row's text after a leading glyph).
class MosaicDivider extends StatelessWidget {
  const MosaicDivider({
    super.key,
    this.thickness = 1,
    this.indent = 0,
    this.endIndent = 0,
    this.color,
  }) : _axis = Axis.horizontal;

  const MosaicDivider.vertical({
    super.key,
    this.thickness = 1,
    this.indent = 0,
    this.endIndent = 0,
    this.color,
  }) : _axis = Axis.vertical;

  final double thickness;
  final double indent;
  final double endIndent;
  final Color? color;
  final Axis _axis;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    final stroke = color ?? tokens.color.divider;
    if (_axis == Axis.horizontal) {
      return Padding(
        padding: EdgeInsets.only(left: indent, right: endIndent),
        child: SizedBox(
          height: thickness,
          child: ColoredBox(color: stroke),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.only(top: indent, bottom: endIndent),
      child: SizedBox(
        width: thickness,
        child: ColoredBox(color: stroke),
      ),
    );
  }
}
