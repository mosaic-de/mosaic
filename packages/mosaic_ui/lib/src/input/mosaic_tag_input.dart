import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../press/mosaic_press_feedback.dart';
import '../theme/mosaic_theme.dart';

/// A text field that converts entered values into tag chips. Type a
/// label and hit enter (or comma) to add a tag; tap × on a tag to
/// remove it.
class MosaicTagInput extends StatefulWidget {
  const MosaicTagInput({
    super.key,
    required this.tags,
    required this.onChanged,
    this.enabled = true,
    this.allowDuplicates = false,
    this.maxTags,
  });

  final List<String> tags;
  final ValueChanged<List<String>>? onChanged;
  final bool enabled;
  final bool allowDuplicates;
  final int? maxTags;

  @override
  State<MosaicTagInput> createState() => _MosaicTagInputState();
}

class _MosaicTagInputState extends State<MosaicTagInput> {
  late final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get _canAddMore =>
      widget.maxTags == null || widget.tags.length < widget.maxTags!;

  void _commit(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return;
    if (!_canAddMore) return;
    if (!widget.allowDuplicates && widget.tags.contains(value)) {
      _controller.clear();
      return;
    }
    widget.onChanged?.call([...widget.tags, value]);
    _controller.clear();
  }

  void _remove(String tag) {
    widget.onChanged?.call([...widget.tags]..remove(tag));
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
            horizontal: tokens.spacing.sm,
            vertical: tokens.spacing.xs,
          ),
          child: Wrap(
            spacing: tokens.spacing.xs,
            runSpacing: tokens.spacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final tag in widget.tags)
                _TagChip(label: tag, onRemove: () => _remove(tag)),
              IntrinsicWidth(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 64),
                  child: SizedBox(
                    height: 28,
                    child: EditableText(
                      controller: _controller,
                      focusNode: _focusNode,
                      readOnly: !widget.enabled || !_canAddMore,
                      style: tokens.typography.body.copyWith(
                        color: tokens.color.textPrimary,
                      ),
                      cursorColor: tokens.color.accent,
                      backgroundCursorColor: tokens.color.surfaceMuted,
                      textInputAction: TextInputAction.done,
                      inputFormatters: [
                        // Commit on comma — strip commas before they
                        // end up in the field.
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          if (newValue.text.endsWith(',')) {
                            final v = newValue.text.substring(
                              0,
                              newValue.text.length - 1,
                            );
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _commit(v);
                            });
                            return oldValue;
                          }
                          return newValue;
                        }),
                      ],
                      onSubmitted: _commit,
                      onChanged: (_) => setState(() {}),
                    ),
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

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.sm,
        vertical: tokens.spacing.xs / 2,
      ),
      decoration: BoxDecoration(
        color: tokens.color.surfaceMuted,
        borderRadius: BorderRadius.circular(tokens.radius.pill),
        border: Border.all(color: tokens.color.divider, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: tokens.typography.tileTitle.copyWith(
              color: tokens.color.textPrimary,
              height: 1,
            ),
          ),
          SizedBox(width: tokens.spacing.xs),
          MosaicPressFeedback(
            onPressed: onRemove,
            semanticLabel: 'Remove $label',
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Text(
                '×',
                style: tokens.typography.tileTitle.copyWith(
                  color: tokens.color.textSecondary,
                  height: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
