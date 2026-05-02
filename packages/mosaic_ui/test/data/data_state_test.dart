import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

void main() {
  group('DataState equality', () {
    test('two idle states are equal', () {
      expect(const DataIdle<int>(), const DataIdle<int>());
    });

    test('two empty states are equal', () {
      expect(const DataEmpty<int>(), const DataEmpty<int>());
    });

    test('idle and empty are not equal', () {
      expect(const DataIdle<int>(), isNot(const DataEmpty<int>()));
    });

    test('loading equality covers lastKnown and isInitial', () {
      expect(
        const DataLoading<int>(isInitial: true),
        const DataLoading<int>(isInitial: true),
      );
      expect(
        const DataLoading<int>(lastKnown: 1),
        isNot(const DataLoading<int>(lastKnown: 2)),
      );
    });

    test('ready equality covers value, isStale, isUpdating', () {
      expect(
        const DataReady<int>(1, isStale: true),
        const DataReady<int>(1, isStale: true),
      );
      expect(
        const DataReady<int>(1),
        isNot(const DataReady<int>(1, isUpdating: true)),
      );
    });

    test('error equality covers error and lastKnown', () {
      expect(const DataError<int>('boom'), const DataError<int>('boom'));
      expect(
        const DataError<int>('boom', lastKnown: 1),
        isNot(const DataError<int>('boom', lastKnown: 2)),
      );
    });
  });

  group('lastKnown / hasValue', () {
    test('idle has no value', () {
      const state = DataIdle<int>();
      expect(state.lastKnown, isNull);
      expect(state.hasValue, isFalse);
    });

    test('empty has no value', () {
      const state = DataEmpty<int>();
      expect(state.lastKnown, isNull);
      expect(state.hasValue, isFalse);
    });

    test('loading carries lastKnown when refresh', () {
      const state = DataLoading<int>(lastKnown: 5);
      expect(state.lastKnown, 5);
      expect(state.hasValue, isTrue);
    });

    test('loading without lastKnown has no value', () {
      const state = DataLoading<int>(isInitial: true);
      expect(state.lastKnown, isNull);
      expect(state.hasValue, isFalse);
    });

    test('ready exposes value as lastKnown', () {
      const state = DataReady<int>(7);
      expect(state.lastKnown, 7);
      expect(state.hasValue, isTrue);
    });

    test('error preserves lastKnown', () {
      const state = DataError<int>('boom', lastKnown: 9);
      expect(state.lastKnown, 9);
      expect(state.hasValue, isTrue);
    });
  });

  group('when() pattern', () {
    String describe(DataState<int> s) => s.when(
      onIdle: () => 'idle',
      onLoading: (lastKnown, isInitial) =>
          'loading(initial=$isInitial,last=$lastKnown)',
      onReady: (value, isStale, isUpdating) =>
          'ready($value,stale=$isStale,updating=$isUpdating)',
      onEmpty: () => 'empty',
      onError: (e, last) => 'error($e,last=$last)',
    );

    test('routes each variant to its handler', () {
      expect(describe(const DataIdle<int>()), 'idle');
      expect(
        describe(const DataLoading<int>(isInitial: true)),
        'loading(initial=true,last=null)',
      );
      expect(
        describe(const DataReady<int>(3)),
        'ready(3,stale=false,updating=false)',
      );
      expect(describe(const DataEmpty<int>()), 'empty');
      expect(
        describe(const DataError<int>('boom', lastKnown: 1)),
        'error(boom,last=1)',
      );
    });
  });

  group('DataReady.copyWith', () {
    test('toggles flags without losing value', () {
      const base = DataReady<int>(42);
      final stale = base.copyWith(isStale: true);
      expect(stale.value, 42);
      expect(stale.isStale, isTrue);
      expect(stale.isUpdating, isFalse);
    });
  });
}
