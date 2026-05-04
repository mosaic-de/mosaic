import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/mosaic_theme.dart';

/// Token-driven PIN / OTP input. Renders [length] digit cells and
/// captures input via a hidden text field — tap anywhere in the row
/// to focus, type to fill cells left-to-right, backspace to clear.
///
/// The [obscured] flag replaces filled digits with `•`.
class MosaicPinInput extends StatefulWidget {
  const MosaicPinInput({
    super.key,
    required this.length,
    this.value,
    this.onChanged,
    this.onCompleted,
    this.obscured = false,
    this.autofocus = false,
    this.enabled = true,
    this.semanticLabel,
  }) : assert(length > 0 && length <= 12, 'length must be 1-12');

  final int length;

  /// Optional controlled value. When null, the widget keeps its own
  /// internal state.
  final String? value;

  final ValueChanged<String>? onChanged;

  /// Fires once the input reaches [length] characters. Useful for
  /// auto-submit on the last digit.
  final ValueChanged<String>? onCompleted;

  final bool obscured;
  final bool autofocus;
  final bool enabled;
  final String? semanticLabel;

  @override
  State<MosaicPinInput> createState() => _MosaicPinInputState();
}

class _MosaicPinInputState extends State<MosaicPinInput> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.value ?? '',
  );
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(covariant MosaicPinInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != null && widget.value != _controller.text) {
      _controller.text = widget.value!;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged() {
    final text = _controller.text;
    widget.onChanged?.call(text);
    if (text.length == widget.length) widget.onCompleted?.call(text);
  }

  void _requestFocus() {
    if (!widget.enabled) return;
    if (!_focusNode.hasFocus) _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    final filled = _controller.text;
    return Semantics(
      label: widget.semanticLabel ?? 'PIN entry',
      textField: true,
      enabled: widget.enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _requestFocus,
        child: Opacity(
          opacity: widget.enabled ? 1 : 0.5,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var i = 0; i < widget.length; i++)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: tokens.spacing.xs / 2,
                      ),
                      child: _Cell(
                        value: i < filled.length
                            ? (widget.obscured ? '•' : filled[i])
                            : '',
                        focused: _focusNode.hasFocus && i == filled.length,
                      ),
                    ),
                ],
              ),
              // Hidden text field that catches the actual keyboard input.
              Positioned.fill(
                child: Opacity(
                  opacity: 0,
                  child: EditableText(
                    controller: _controller,
                    focusNode: _focusNode,
                    autofocus: widget.autofocus,
                    readOnly: !widget.enabled,
                    obscureText: widget.obscured,
                    style: tokens.typography.metric,
                    cursorColor: tokens.color.accent,
                    backgroundCursorColor: tokens.color.surfaceMuted,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(widget.length),
                    ],
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.value, required this.focused});

  final String value;
  final bool focused;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    final hasValue = value.isNotEmpty;
    final borderColor = focused
        ? tokens.color.accent
        : hasValue
        ? tokens.color.textPrimary
        : tokens.color.divider;
    return Container(
      width: 44,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tokens.color.surface,
        border: Border.all(color: borderColor, width: focused ? 2 : 1.5),
        borderRadius: BorderRadius.circular(tokens.radius.input),
      ),
      child: Text(
        value,
        style: tokens.typography.metric.copyWith(
          color: tokens.color.textPrimary,
          height: 1,
        ),
      ),
    );
  }
}
