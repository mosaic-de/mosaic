import 'package:flutter/foundation.dart';

/// Interaction state for any pressable Mosaic surface.
///
/// The four flags are independent: a widget can be both `focused` and
/// `pressed`, or `hovered` and `disabled` (the latter renders as disabled
/// but tracks hover for cursor purposes). Visual feedback resolves the
/// combination via priority (disabled > pressed > focused > hovered > idle).
@immutable
class InteractionState {
  const InteractionState({
    this.pressed = false,
    this.hovered = false,
    this.focused = false,
    this.disabled = false,
  });

  static const InteractionState idle = InteractionState();

  final bool pressed;
  final bool hovered;
  final bool focused;
  final bool disabled;

  bool get isIdle => !pressed && !hovered && !focused && !disabled;

  InteractionState copyWith({
    bool? pressed,
    bool? hovered,
    bool? focused,
    bool? disabled,
  }) {
    return InteractionState(
      pressed: pressed ?? this.pressed,
      hovered: hovered ?? this.hovered,
      focused: focused ?? this.focused,
      disabled: disabled ?? this.disabled,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InteractionState &&
        other.pressed == pressed &&
        other.hovered == hovered &&
        other.focused == focused &&
        other.disabled == disabled;
  }

  @override
  int get hashCode => Object.hash(pressed, hovered, focused, disabled);

  @override
  String toString() {
    if (isIdle) return 'InteractionState.idle';
    final flags = <String>[
      if (pressed) 'pressed',
      if (hovered) 'hovered',
      if (focused) 'focused',
      if (disabled) 'disabled',
    ];
    return 'InteractionState(${flags.join(', ')})';
  }
}
