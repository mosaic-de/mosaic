import 'package:flutter/widgets.dart';

import '../list/mosaic_list.dart';
import '../press/mosaic_press_feedback.dart';
import '../state/mosaic_empty_state.dart';
import '../surface/mosaic_panel.dart';
import '../surface/mosaic_surface.dart';
import '../surface/mosaic_surface_host.dart';
import '../surface/mosaic_surface_kind.dart';
import '../theme/mosaic_theme.dart';
import 'mosaic_input.dart';
import 'mosaic_select.dart';

/// Same surface-pushing model as [MosaicSelect], but the picker panel
/// has a search input across the top that filters the option list as
/// you type.
///
/// Use this when the option count crosses the "scroll a long list to
/// pick one" threshold (~15+). Below that, prefer [MosaicSelect] —
/// adding a search input to a 5-row list is friction.
class MosaicSearchableSelect<T> extends StatelessWidget {
  const MosaicSearchableSelect({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.placeholder,
    this.title = 'Select',
    this.searchPlaceholder = 'Search',
    this.enabled = true,
  });

  final T? value;
  final List<MosaicSelectOption<T>> options;
  final ValueChanged<T>? onChanged;
  final String? placeholder;
  final String title;
  final String searchPlaceholder;
  final bool enabled;

  String? get _currentLabel {
    if (value == null) return null;
    for (final option in options) {
      if (option.value == value) return option.label;
    }
    return null;
  }

  void _open(BuildContext context) {
    final scope = MosaicSurfaceScope.of(context);
    scope.push(
      (panelContext) => _SearchablePanel<T>(
        title: title,
        searchPlaceholder: searchPlaceholder,
        currentValue: value,
        options: options,
        onPicked: (picked) {
          onChanged?.call(picked);
          MosaicSurfaceScope.of(panelContext).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    final label = _currentLabel ?? placeholder ?? '';
    final hasValue = _currentLabel != null;
    return MosaicPressFeedback(
      onPressed: enabled ? () => _open(context) : null,
      enabled: enabled,
      semanticLabel: hasValue ? label : (placeholder ?? title),
      child: Container(
        decoration: BoxDecoration(
          color: tokens.color.surface,
          borderRadius: BorderRadius.circular(tokens.radius.input),
          border: Border.all(color: tokens.color.divider, width: 1),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spacing.md,
          vertical: tokens.spacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: tokens.typography.body.copyWith(
                  color: hasValue
                      ? tokens.color.textPrimary
                      : tokens.color.textSecondary.withValues(alpha: 0.7),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: tokens.spacing.sm),
            Text(
              '⌕',
              style: tokens.typography.body.copyWith(
                color: tokens.color.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchablePanel<T> extends StatefulWidget {
  const _SearchablePanel({
    required this.title,
    required this.searchPlaceholder,
    required this.currentValue,
    required this.options,
    required this.onPicked,
  });

  final String title;
  final String searchPlaceholder;
  final T? currentValue;
  final List<MosaicSelectOption<T>> options;
  final ValueChanged<T> onPicked;

  @override
  State<_SearchablePanel<T>> createState() => _SearchablePanelState<T>();
}

class _SearchablePanelState<T> extends State<_SearchablePanel<T>> {
  final TextEditingController _query = TextEditingController();

  @override
  void initState() {
    super.initState();
    _query.addListener(_onQueryChanged);
  }

  void _onQueryChanged() => setState(() {});

  @override
  void dispose() {
    _query.removeListener(_onQueryChanged);
    _query.dispose();
    super.dispose();
  }

  List<MosaicSelectOption<T>> get _filtered {
    final raw = _query.text.trim().toLowerCase();
    if (raw.isEmpty) return widget.options;
    return widget.options
        .where((o) => o.label.toLowerCase().contains(raw))
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    final scope = MosaicSurfaceScope.of(context);
    final filtered = _filtered;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.md,
        vertical: tokens.spacing.md,
      ),
      child: MosaicPanel(
        padding: EdgeInsets.all(tokens.spacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                MosaicPressFeedback(
                  onPressed: scope.pop,
                  semanticLabel: 'Cancel',
                  child: MosaicSurface(
                    kind: MosaicSurfaceKind.muted,
                    padding: EdgeInsets.symmetric(
                      horizontal: tokens.spacing.sm,
                      vertical: tokens.spacing.xs,
                    ),
                    child: Text(
                      '←',
                      style: tokens.typography.title.copyWith(
                        color: tokens.color.textPrimary,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: tokens.spacing.md),
                Expanded(
                  child: Text(
                    widget.title,
                    style: tokens.typography.title.copyWith(
                      color: tokens.color.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.spacing.md),
            MosaicSearchInput(
              controller: _query,
              placeholder: widget.searchPlaceholder,
              autofocus: true,
            ),
            SizedBox(height: tokens.spacing.md),
            Flexible(
              child: filtered.isEmpty
                  ? const MosaicEmptyState(title: 'No matches', glyph: '⌕')
                  : MosaicList(
                      shrinkWrap: true,
                      rows: [
                        for (final option in filtered)
                          MosaicListRow(
                            title: option.label,
                            trailing: option.value == widget.currentValue
                                ? Text(
                                    '✓',
                                    style: tokens.typography.body.copyWith(
                                      color: tokens.color.accent,
                                    ),
                                  )
                                : null,
                            onPressed: () => widget.onPicked(option.value),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
