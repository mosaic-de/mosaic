import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/mosaic_theme.dart';
import '../tokens/mosaic_tokens.dart';

/// Token-driven text input. No Material, no platform-specific chrome —
/// just a [MosaicSurface]-shaped container with an [EditableText] inside.
///
/// Pass a [controller] to read or seed the value from the outside;
/// otherwise the widget keeps its own internal one.
class MosaicInput extends StatefulWidget {
  const MosaicInput({
    super.key,
    this.controller,
    this.initialValue,
    this.placeholder,
    this.leading,
    this.trailing,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.obscured = false,
    this.enabled = true,
    this.semanticLabel,
    this.inputFormatters,
    this.keyboardType,
    this.textInputAction,
  }) : assert(
         controller == null || initialValue == null,
         'Provide either controller or initialValue, not both.',
       );

  final TextEditingController? controller;
  final String? initialValue;
  final String? placeholder;
  final Widget? leading;
  final Widget? trailing;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final bool obscured;
  final bool enabled;
  final String? semanticLabel;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  @override
  State<MosaicInput> createState() => _MosaicInputState();
}

class _MosaicInputState extends State<MosaicInput> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController(text: widget.initialValue);
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    final has = _focusNode.hasFocus;
    if (_focused != has) setState(() => _focused = has);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  void _requestFocus() {
    if (!widget.enabled) return;
    if (!_focusNode.hasFocus) _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    final disabled = !widget.enabled;
    final borderColor = disabled
        ? tokens.color.divider
        : (_focused ? tokens.color.accent : tokens.color.divider);
    final borderWidth = _focused && !disabled ? 2.0 : 1.0;

    return Semantics(
      label: widget.semanticLabel,
      textField: true,
      enabled: widget.enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _requestFocus,
        child: AnimatedOpacity(
          opacity: disabled ? 0.5 : 1.0,
          duration: tokens.motion.scaledUpdate,
          curve: tokens.motion.standardCurve,
          child: Container(
            decoration: BoxDecoration(
              color: tokens.color.surface,
              borderRadius: BorderRadius.circular(tokens.radius.input),
              border: Border.all(color: borderColor, width: borderWidth),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: tokens.spacing.md,
              vertical: tokens.spacing.sm,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.leading != null) ...[
                  DefaultTextStyle(
                    style: tokens.typography.title.copyWith(
                      color: tokens.color.textSecondary,
                    ),
                    child: widget.leading!,
                  ),
                  SizedBox(width: tokens.spacing.sm),
                ],
                Expanded(child: _buildField(tokens)),
                if (widget.trailing != null) ...[
                  SizedBox(width: tokens.spacing.sm),
                  widget.trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(MosaicTokens tokens) {
    final textStyle = tokens.typography.body.copyWith(
      color: tokens.color.textPrimary,
    );
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            if (_controller.text.isNotEmpty || widget.placeholder == null) {
              return const SizedBox.shrink();
            }
            return Text(
              widget.placeholder!,
              style: textStyle.copyWith(
                color: tokens.color.textSecondary.withValues(alpha: 0.7),
              ),
            );
          },
        ),
        EditableText(
          controller: _controller,
          focusNode: _focusNode,
          readOnly: !widget.enabled,
          autofocus: widget.autofocus,
          obscureText: widget.obscured,
          style: textStyle,
          cursorColor: tokens.color.accent,
          backgroundCursorColor: tokens.color.surfaceMuted,
          selectionColor: tokens.color.accent.withValues(alpha: 0.3),
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          inputFormatters: widget.inputFormatters,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
        ),
      ],
    );
  }
}

/// Convenience preset: a [MosaicInput] shaped for search.
class MosaicSearchInput extends StatelessWidget {
  const MosaicSearchInput({
    super.key,
    this.controller,
    this.placeholder = 'Search',
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final String placeholder;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return MosaicInput(
      controller: controller,
      placeholder: placeholder,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      autofocus: autofocus,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      semanticLabel: placeholder,
      leading: const Text('⌕'),
    );
  }
}
