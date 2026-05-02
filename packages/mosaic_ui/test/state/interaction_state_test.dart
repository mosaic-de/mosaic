import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

void main() {
  group('InteractionState', () {
    test('idle has all flags false', () {
      const state = InteractionState.idle;
      expect(state.pressed, isFalse);
      expect(state.hovered, isFalse);
      expect(state.focused, isFalse);
      expect(state.disabled, isFalse);
      expect(state.isIdle, isTrue);
    });

    test('flags compose independently', () {
      const state = InteractionState(pressed: true, focused: true);
      expect(state.pressed, isTrue);
      expect(state.focused, isTrue);
      expect(state.hovered, isFalse);
      expect(state.isIdle, isFalse);
    });

    test('equality is by value', () {
      expect(
        const InteractionState(pressed: true),
        const InteractionState(pressed: true),
      );
      expect(
        const InteractionState(pressed: true),
        isNot(const InteractionState(pressed: true, hovered: true)),
      );
    });

    test('copyWith preserves untouched flags', () {
      const base = InteractionState(focused: true);
      final copy = base.copyWith(pressed: true);
      expect(copy.focused, isTrue);
      expect(copy.pressed, isTrue);
      expect(copy.hovered, isFalse);
    });

    test('toString is informative', () {
      expect(InteractionState.idle.toString(), 'InteractionState.idle');
      expect(
        const InteractionState(pressed: true, focused: true).toString(),
        contains('pressed'),
      );
    });
  });
}
