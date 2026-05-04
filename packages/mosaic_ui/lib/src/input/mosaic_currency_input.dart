import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/mosaic_theme.dart';

/// Token-driven money input. Holds an integer minor-unit value (cents)
/// and renders a formatted display with an optional currency code as
/// a leading badge.
///
/// The input only accepts digits and one decimal separator; commits a
/// minor-unit `int` via [onChanged] (e.g. typing `12.34` with USD →
/// `1234`).
class MosaicCurrencyInput extends StatefulWidget {
  const MosaicCurrencyInput({
    super.key,
    required this.cents,
    required this.onChanged,
    this.currency = 'KES',
    this.minorUnits = 2,
    this.placeholder = '0.00',
    this.enabled = true,
    this.autofocus = false,
  }) : assert(minorUnits >= 0 && minorUnits <= 4, 'minorUnits must be 0..4');

  /// Value in minor units (cents for currencies with 2 minor units).
  final int cents;

  final ValueChanged<int>? onChanged;
  final String currency;
  final int minorUnits;
  final String placeholder;
  final bool enabled;
  final bool autofocus;

  @override
  State<MosaicCurrencyInput> createState() => _MosaicCurrencyInputState();
}

class _MosaicCurrencyInputState extends State<MosaicCurrencyInput> {
  late final TextEditingController _controller = TextEditingController(
    text: _format(widget.cents, widget.minorUnits),
  );
  final FocusNode _focusNode = FocusNode();

  @override
  void didUpdateWidget(covariant MosaicCurrencyInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cents != oldWidget.cents && !_focusNode.hasFocus) {
      _controller.text = _format(widget.cents, widget.minorUnits);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  static String _format(int cents, int minorUnits) {
    if (minorUnits == 0) return cents.toString();
    final divisor = _pow10(minorUnits);
    final whole = cents ~/ divisor;
    final fraction = (cents % divisor).abs();
    return '$whole.${fraction.toString().padLeft(minorUnits, '0')}';
  }

  static int _pow10(int n) {
    var v = 1;
    for (var i = 0; i < n; i++) {
      v *= 10;
    }
    return v;
  }

  void _onChanged(String raw) {
    final parsed = double.tryParse(raw);
    if (parsed == null) return;
    final cents = (parsed * _pow10(widget.minorUnits)).round();
    widget.onChanged?.call(cents);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    final hasFocus = _focusNode.hasFocus;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _focusNode.requestFocus(),
      child: Opacity(
        opacity: widget.enabled ? 1 : 0.5,
        child: Container(
          decoration: BoxDecoration(
            color: tokens.color.surface,
            borderRadius: BorderRadius.circular(tokens.radius.input),
            border: Border.all(
              color: hasFocus ? tokens.color.accent : tokens.color.divider,
              width: hasFocus ? 2 : 1,
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: tokens.spacing.md,
            vertical: tokens.spacing.sm,
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: tokens.spacing.sm,
                  vertical: tokens.spacing.xs / 2,
                ),
                decoration: BoxDecoration(
                  color: tokens.color.surfaceMuted,
                  borderRadius: BorderRadius.circular(tokens.radius.pill),
                  border: Border.all(color: tokens.color.divider, width: 1),
                ),
                child: Text(
                  widget.currency,
                  style: tokens.typography.caption.copyWith(
                    color: tokens.color.textSecondary,
                    fontWeight: FontWeight.w500,
                    height: 1,
                  ),
                ),
              ),
              SizedBox(width: tokens.spacing.md),
              Expanded(
                child: EditableText(
                  controller: _controller,
                  focusNode: _focusNode,
                  autofocus: widget.autofocus,
                  readOnly: !widget.enabled,
                  style: tokens.typography.title.copyWith(
                    color: tokens.color.textPrimary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    height: 1.1,
                  ),
                  cursorColor: tokens.color.accent,
                  backgroundCursorColor: tokens.color.surfaceMuted,
                  selectionColor: tokens.color.accent.withValues(alpha: 0.3),
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.numberWithOptions(
                    decimal: widget.minorUnits > 0,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      widget.minorUnits > 0
                          ? RegExp(r'[0-9.]')
                          : RegExp(r'[0-9]'),
                    ),
                  ],
                  onChanged: _onChanged,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
