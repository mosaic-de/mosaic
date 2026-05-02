@Tags(<String>['golden'])
library;

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

import '_harness.dart';

Widget _liveTile(MosaicTokens tokens, MosaicLiveSource<int> source) {
  return SizedBox(
    width: 160,
    height: 160,
    child: MosaicLiveTile<int>(
      size: MosaicTileSize.medium,
      source: source,
      padding: EdgeInsets.all(tokens.spacing.md),
      tileBuilder: (context, value, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Counter',
            style: tokens.typography.tileSubtitle.copyWith(
              color: tokens.color.textSecondary,
            ),
          ),
          SizedBox(height: tokens.spacing.xs),
          Text(
            '$value',
            style: tokens.typography.metric.copyWith(
              color: tokens.color.textPrimary,
            ),
          ),
        ],
      ),
    ),
  );
}

void main() {
  testWidgets('live tile ready', (tester) async {
    final source = MosaicLiveSource<int>.static(42);
    addTearDown(source.dispose);
    await runGoldenMatrix(
      tester,
      name: 'live_tile_ready',
      builder: (tokens) => _liveTile(tokens, source),
    );
  });

  testWidgets('live tile loading', (tester) async {
    final controller = StreamController<int>();
    addTearDown(controller.close);
    final source = MosaicLiveSource<int>.fromStream(controller.stream);
    addTearDown(source.dispose);
    await runGoldenMatrix(
      tester,
      name: 'live_tile_loading',
      builder: (tokens) => _liveTile(tokens, source),
    );
  });

  testWidgets('live tile empty', (tester) async {
    final source = MosaicLiveSource<int>.empty();
    addTearDown(source.dispose);
    await runGoldenMatrix(
      tester,
      name: 'live_tile_empty',
      builder: (tokens) => _liveTile(tokens, source),
    );
  });

  testWidgets('live tile error', (tester) async {
    final controller = StreamController<int>();
    final source = MosaicLiveSource<int>.fromStream(controller.stream);
    addTearDown(source.dispose);
    controller.addError('boom');
    await runGoldenMatrix(
      tester,
      name: 'live_tile_error',
      builder: (tokens) => _liveTile(tokens, source),
    );
    await controller.close();
  });
}
