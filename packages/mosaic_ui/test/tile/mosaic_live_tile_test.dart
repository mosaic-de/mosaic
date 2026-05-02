import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

Widget _wrap(Widget child) {
  return MosaicTheme.test(
    child: Center(child: SizedBox(width: 240, height: 240, child: child)),
  );
}

void main() {
  testWidgets('renders tileBuilder when source is ready', (tester) async {
    final source = MosaicLiveSource<int>.static(42);
    addTearDown(source.dispose);
    await tester.pumpWidget(
      _wrap(
        MosaicLiveTile<int>(
          size: MosaicTileSize.medium,
          source: source,
          tileBuilder: (context, value, _) =>
              Text('v=$value', textDirection: TextDirection.ltr),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('v=42'), findsOneWidget);
  });

  testWidgets('renders loading body when no value yet', (tester) async {
    final controller = StreamController<int>();
    addTearDown(controller.close);
    final source = MosaicLiveSource<int>.fromStream(controller.stream);
    addTearDown(source.dispose);

    await tester.pumpWidget(
      _wrap(
        MosaicLiveTile<int>(
          size: MosaicTileSize.medium,
          source: source,
          tileBuilder: (context, value, _) =>
              Text('v=$value', textDirection: TextDirection.ltr),
          loadingBuilder: (_) =>
              const Text('loading', textDirection: TextDirection.ltr),
        ),
      ),
    );
    expect(find.text('loading'), findsOneWidget);
    expect(find.text('v=0'), findsNothing);
  });

  testWidgets('renders empty body when source emits empty', (tester) async {
    final source = MosaicLiveSource<int>.empty();
    addTearDown(source.dispose);

    await tester.pumpWidget(
      _wrap(
        MosaicLiveTile<int>(
          size: MosaicTileSize.medium,
          source: source,
          tileBuilder: (context, value, _) =>
              Text('v=$value', textDirection: TextDirection.ltr),
          emptyBuilder: (_) =>
              const Text('empty', textDirection: TextDirection.ltr),
        ),
      ),
    );
    expect(find.text('empty'), findsOneWidget);
  });

  testWidgets('preserves lastKnown during refresh (does not flicker)', (
    tester,
  ) async {
    var counter = 0;
    final source = MosaicLiveSource<int>.fromFuture(() {
      final c = Completer<int>();
      Future<void>.microtask(() => c.complete(++counter));
      return c.future;
    }, interval: const Duration(milliseconds: 5));

    await tester.pumpWidget(
      _wrap(
        MosaicLiveTile<int>(
          size: MosaicTileSize.medium,
          source: source,
          tileBuilder: (context, value, _) =>
              Text('v=$value', textDirection: TextDirection.ltr),
          loadingBuilder: (_) =>
              const Text('loading', textDirection: TextDirection.ltr),
        ),
      ),
    );
    // First fetch resolved during pumpWidget's microtask drain.
    expect(find.text('v=1'), findsOneWidget);

    // Advance past the interval. The refresh timer fires, the source
    // emits DataReady(1, isUpdating: true), then runs the next fetch.
    // Throughout, the tile must keep showing v=1 — never 'loading'.
    await tester.pump(const Duration(milliseconds: 6));
    expect(find.text('loading'), findsNothing);
    expect(find.textContaining('v='), findsOneWidget);

    // Dispose explicitly to cancel the still-pending interval timer
    // before the binding checks for leaked timers.
    source.dispose();
  });

  testWidgets('renders error skeleton when source errors with no lastKnown', (
    tester,
  ) async {
    final controller = StreamController<int>();
    addTearDown(controller.close);
    final source = MosaicLiveSource<int>.fromStream(controller.stream);
    addTearDown(source.dispose);

    await tester.pumpWidget(
      _wrap(
        MosaicLiveTile<int>(
          size: MosaicTileSize.medium,
          source: source,
          tileBuilder: (context, value, _) =>
              Text('v=$value', textDirection: TextDirection.ltr),
          errorBuilder: (_, error) =>
              Text('err=$error', textDirection: TextDirection.ltr),
        ),
      ),
    );

    controller.addError('boom');
    await tester.pump();
    await tester.pump();
    expect(find.text('err=boom'), findsOneWidget);
  });

  testWidgets('shows lastKnown value even when error fires after success', (
    tester,
  ) async {
    final controller = StreamController<int>();
    addTearDown(controller.close);
    final source = MosaicLiveSource<int>.fromStream(controller.stream);
    addTearDown(source.dispose);

    await tester.pumpWidget(
      _wrap(
        MosaicLiveTile<int>(
          size: MosaicTileSize.medium,
          source: source,
          tileBuilder: (context, value, _) =>
              Text('v=$value', textDirection: TextDirection.ltr),
          errorBuilder: (_, error) =>
              Text('err=$error', textDirection: TextDirection.ltr),
        ),
      ),
    );

    controller.add(7);
    await tester.pump();
    await tester.pump();
    expect(find.text('v=7'), findsOneWidget);

    controller.addError('boom');
    await tester.pump();
    await tester.pump();
    // Must still show the value, not the error skeleton.
    expect(find.text('v=7'), findsOneWidget);
    expect(find.text('err=boom'), findsNothing);
  });
}
