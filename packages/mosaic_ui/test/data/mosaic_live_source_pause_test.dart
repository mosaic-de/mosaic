import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

void main() {
  group('Stream source pause/resume', () {
    test('pause stops forwarding new values', () async {
      final ctrl = StreamController<int>();
      final src = MosaicLiveSource.fromStream(ctrl.stream);
      ctrl.add(1);
      await Future<void>.delayed(Duration.zero);
      expect((src.current as DataReady<int>).value, 1);

      src.pause();
      expect(src.isPaused, isTrue);
      ctrl.add(2);
      await Future<void>.delayed(Duration.zero);
      // Still 1 — paused subscription buffers the value.
      expect((src.current as DataReady<int>).value, 1);

      src.resume();
      await Future<void>.delayed(Duration.zero);
      expect((src.current as DataReady<int>).value, 2);

      await ctrl.close();
      src.dispose();
    });
  });

  group('Future source pause/resume', () {
    test('pause cancels the next scheduled fetch', () async {
      var calls = 0;
      Future<int> fetch() async {
        calls += 1;
        return calls;
      }

      final src = MosaicLiveSource.fromFuture(
        fetch,
        interval: const Duration(milliseconds: 20),
      );
      // Wait for the initial fetch.
      await Future<void>.delayed(const Duration(milliseconds: 5));
      expect(calls, 1);

      src.pause();
      // No follow-up fetches should fire while paused.
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(calls, 1);

      src.resume();
      // Resume kicks off a fetch immediately.
      await Future<void>.delayed(const Duration(milliseconds: 5));
      expect(calls, 2);

      src.dispose();
    });
  });

  group('Static source pause/resume', () {
    test('pause/resume are no-ops on static and empty sources', () {
      final MosaicLiveSource<int> stat = MosaicLiveSource<int>.static(7);
      stat.pause();
      stat.resume();
      expect((stat.current as DataReady<int>).value, 7);
      stat.dispose();

      final MosaicLiveSource<int> empty = MosaicLiveSource<int>.empty();
      empty.pause();
      empty.resume();
      expect(empty.current, isA<DataEmpty<int>>());
      empty.dispose();
    });
  });
}
