import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

void main() {
  group('MosaicLiveSource.static', () {
    test('emits DataReady once and keeps it as current', () async {
      final source = MosaicLiveSource<int>.static(42);
      addTearDown(source.dispose);

      expect(source.current, const DataReady<int>(42));
      final first = await source.states.first;
      expect(first, const DataReady<int>(42));
    });
  });

  group('MosaicLiveSource.empty', () {
    test('current is DataEmpty', () {
      final source = MosaicLiveSource<int>.empty();
      addTearDown(source.dispose);
      expect(source.current, const DataEmpty<int>());
    });
  });

  group('MosaicLiveSource.fromStream', () {
    test('starts in DataLoading(isInitial: true)', () {
      final controller = StreamController<int>();
      addTearDown(controller.close);
      final source = MosaicLiveSource<int>.fromStream(controller.stream);
      addTearDown(source.dispose);
      expect(source.current, const DataLoading<int>(isInitial: true));
    });

    test('transitions to DataReady on first value', () async {
      final controller = StreamController<int>();
      addTearDown(controller.close);
      final source = MosaicLiveSource<int>.fromStream(controller.stream);
      addTearDown(source.dispose);

      controller.add(1);
      await Future<void>.delayed(Duration.zero);

      expect(source.current, const DataReady<int>(1));
    });

    test('preserves lastKnown when stream errors after a ready', () async {
      final controller = StreamController<int>();
      addTearDown(controller.close);
      final source = MosaicLiveSource<int>.fromStream(controller.stream);
      addTearDown(source.dispose);

      controller.add(7);
      await Future<void>.delayed(Duration.zero);
      controller.addError('boom');
      await Future<void>.delayed(Duration.zero);

      final state = source.current;
      expect(state, isA<DataError<int>>());
      expect(state.lastKnown, 7);
    });

    test('initialValue starts in DataReady', () {
      final controller = StreamController<int>();
      addTearDown(controller.close);
      final source = MosaicLiveSource<int>.fromStream(
        controller.stream,
        initialValue: 11,
      );
      addTearDown(source.dispose);
      expect(source.current, const DataReady<int>(11));
    });

    test('isEmpty predicate routes empty values to DataEmpty', () async {
      final controller = StreamController<List<int>>();
      addTearDown(controller.close);
      final source = MosaicLiveSource<List<int>>.fromStream(
        controller.stream,
        isEmpty: (xs) => xs.isEmpty,
      );
      addTearDown(source.dispose);

      controller.add(<int>[]);
      await Future<void>.delayed(Duration.zero);

      expect(source.current, const DataEmpty<List<int>>());
    });

    test('stream done with no values transitions to DataEmpty', () async {
      final controller = StreamController<int>();
      final source = MosaicLiveSource<int>.fromStream(controller.stream);
      addTearDown(source.dispose);

      await controller.close();
      await Future<void>.delayed(Duration.zero);

      expect(source.current, const DataEmpty<int>());
    });
  });

  group('MosaicLiveSource.fromFuture', () {
    test('emits DataReady on success', () async {
      final source = MosaicLiveSource<int>.fromFuture(() async => 5);
      addTearDown(source.dispose);
      expect(source.current, const DataLoading<int>(isInitial: true));

      await Future<void>.delayed(Duration.zero);
      expect(source.current, const DataReady<int>(5));
    });

    test('emits DataError with no lastKnown on first-fetch failure', () async {
      final source = MosaicLiveSource<int>.fromFuture(
        () async => throw StateError('boom'),
      );
      addTearDown(source.dispose);

      await Future<void>.delayed(Duration.zero);
      final state = source.current;
      expect(state, isA<DataError<int>>());
      expect(state.lastKnown, isNull);
    });

    test(
      'refresh preserves lastKnown via DataReady(isUpdating: true)',
      () async {
        var counter = 0;
        final updates = <DataState<int>>[];
        final source = MosaicLiveSource<int>.fromFuture(
          () async => ++counter,
          interval: const Duration(milliseconds: 5),
        );
        addTearDown(source.dispose);

        final sub = source.states.listen(updates.add);
        addTearDown(sub.cancel);

        await Future<void>.delayed(const Duration(milliseconds: 30));

        // We should see at least: loading(initial), ready(1),
        // ready(1, isUpdating: true), ready(2), ...
        expect(updates.first, const DataLoading<int>(isInitial: true));
        final hasIsUpdating = updates.any(
          (s) => s is DataReady<int> && s.isUpdating && s.value == 1,
        );
        expect(hasIsUpdating, isTrue, reason: 'expected an isUpdating tick');
      },
    );

    test('refresh failure preserves lastKnown in DataError', () async {
      var firstCall = true;
      final source = MosaicLiveSource<int>.fromFuture(() async {
        if (firstCall) {
          firstCall = false;
          return 4;
        }
        throw StateError('refresh failed');
      }, interval: const Duration(milliseconds: 5));
      addTearDown(source.dispose);

      await Future<void>.delayed(const Duration(milliseconds: 30));

      final state = source.current;
      expect(state, isA<DataError<int>>());
      expect(state.lastKnown, 4);
    });
  });

  group('MosaicLiveSource.fromListenable', () {
    test('current reflects listenable value', () {
      final notifier = ValueNotifier<int>(3);
      addTearDown(notifier.dispose);
      final source = MosaicLiveSource<int>.fromListenable(notifier);
      addTearDown(source.dispose);

      expect(source.current, const DataReady<int>(3));
    });

    test('emits DataReady on listenable change', () async {
      final notifier = ValueNotifier<int>(0);
      addTearDown(notifier.dispose);
      final source = MosaicLiveSource<int>.fromListenable(notifier);
      addTearDown(source.dispose);

      final captured = <DataState<int>>[];
      final sub = source.states.listen(captured.add);
      addTearDown(sub.cancel);

      notifier.value = 1;
      notifier.value = 2;
      await Future<void>.delayed(Duration.zero);

      expect(captured, contains(const DataReady<int>(1)));
      expect(captured, contains(const DataReady<int>(2)));
    });
  });

  group('multicast behavior', () {
    test('new subscriber receives current state immediately', () async {
      final source = MosaicLiveSource<int>.static(99);
      addTearDown(source.dispose);

      final first = await source.states.first;
      expect(first, const DataReady<int>(99));

      // A second listener should also see DataReady(99) right away.
      final second = await source.states.first;
      expect(second, const DataReady<int>(99));
    });

    test('dispose releases controller and stream completes', () async {
      final controller = StreamController<int>();
      final source = MosaicLiveSource<int>.fromStream(controller.stream);
      source.dispose();
      await controller.close();

      // After dispose, listening should still complete (with the snapshot).
      final received = await source.states.toList();
      expect(received, isNotEmpty);
    });
  });
}
