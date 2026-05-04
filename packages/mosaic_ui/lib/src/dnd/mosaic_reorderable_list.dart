import 'package:flutter/widgets.dart';

import 'mosaic_dnd.dart';

/// Vertical list of children that the user can long-press and drag to
/// reorder. Each child becomes both a draggable source and a drop
/// target keyed on its index.
///
/// This is the list-shaped peer of [MosaicReorderableGrid]. For static
/// rows reach for [MosaicList].
class MosaicReorderableList extends StatelessWidget {
  const MosaicReorderableList({
    super.key,
    required this.children,
    required this.onReorder,
    this.shrinkWrap = false,
    this.padding,
    this.enabled = true,
    this.longPress = true,
  });

  final List<Widget> children;
  final void Function(int oldIndex, int newIndex) onReorder;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;

  /// Disables drag start. The list still renders; the reorder gesture
  /// is suppressed.
  final bool enabled;

  /// Long-press to start the drag (default). False uses immediate drag.
  final bool longPress;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: shrinkWrap,
      padding: padding,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      itemCount: children.length,
      itemBuilder: (context, i) => _ReorderRow(
        index: i,
        onReorder: onReorder,
        enabled: enabled,
        longPress: longPress,
        child: children[i],
      ),
    );
  }
}

class _ReorderRow extends StatelessWidget {
  const _ReorderRow({
    required this.index,
    required this.onReorder,
    required this.enabled,
    required this.longPress,
    required this.child,
  });

  final int index;
  final void Function(int oldIndex, int newIndex) onReorder;
  final bool enabled;
  final bool longPress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final draggable = MosaicDraggable<int>(
      data: index,
      enabled: enabled,
      longPress: longPress,
      child: child,
    );
    if (!enabled) return draggable;
    return MosaicDropTarget<int>(
      canAccept: (from) => from != index,
      onAccept: (from) {
        if (from == index) return;
        onReorder(from, index);
      },
      child: draggable,
    );
  }
}
