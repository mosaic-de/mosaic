@Tags(<String>['golden'])
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

import '_harness.dart';

Widget _wallet(MosaicTokens tokens) {
  return Padding(
    padding: EdgeInsets.all(tokens.spacing.md),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Balance',
          style: tokens.typography.tileSubtitle.copyWith(
            color: tokens.color.textSecondary,
          ),
        ),
        SizedBox(height: tokens.spacing.xs),
        Text(
          'KES 12,450.00',
          style: tokens.typography.headline.copyWith(
            color: tokens.color.textPrimary,
          ),
        ),
      ],
    ),
  );
}

void main() {
  testWidgets('tile medium', (tester) async {
    await runGoldenMatrix(
      tester,
      name: 'tile_medium',
      builder: (tokens) => SizedBox(
        width: 160,
        height: 160,
        child: MosaicTile(
          size: MosaicTileSize.medium,
          padding: EdgeInsets.all(tokens.spacing.md),
          child: Text(
            'Send',
            style: tokens.typography.tileTitle.copyWith(
              color: tokens.color.textPrimary,
            ),
          ),
        ),
      ),
    );
  });

  testWidgets('tile wide with content', (tester) async {
    await runGoldenMatrix(
      tester,
      name: 'tile_wide',
      size: const Size(420, 220),
      builder: (tokens) => SizedBox(
        width: 360,
        height: 160,
        child: MosaicTile(size: MosaicTileSize.wide, child: _wallet(tokens)),
      ),
    );
  });
}
