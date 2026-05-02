@Tags(<String>['golden'])
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

import '_harness.dart';

void main() {
  testWidgets('surface tile kind', (tester) async {
    await runGoldenMatrix(
      tester,
      name: 'surface_tile',
      builder: (tokens) => SizedBox(
        width: 160,
        height: 100,
        child: MosaicSurface(
          padding: EdgeInsets.all(tokens.spacing.md),
          child: Text(
            'tile',
            style: tokens.typography.tileTitle.copyWith(
              color: tokens.color.textPrimary,
            ),
          ),
        ),
      ),
    );
  });

  testWidgets('surface panel kind', (tester) async {
    await runGoldenMatrix(
      tester,
      name: 'surface_panel',
      builder: (tokens) => SizedBox(
        width: 240,
        height: 140,
        child: MosaicSurface(
          kind: MosaicSurfaceKind.panel,
          padding: EdgeInsets.all(tokens.spacing.md),
          child: Text(
            'panel',
            style: tokens.typography.title.copyWith(
              color: tokens.color.textPrimary,
            ),
          ),
        ),
      ),
    );
  });

  testWidgets('surface muted kind', (tester) async {
    await runGoldenMatrix(
      tester,
      name: 'surface_muted',
      builder: (tokens) => SizedBox(
        width: 160,
        height: 100,
        child: MosaicSurface(
          kind: MosaicSurfaceKind.muted,
          padding: EdgeInsets.all(tokens.spacing.md),
          child: Text(
            'muted',
            style: tokens.typography.tileTitle.copyWith(
              color: tokens.color.textSecondary,
            ),
          ),
        ),
      ),
    );
  });

  testWidgets('surface active state', (tester) async {
    await runGoldenMatrix(
      tester,
      name: 'surface_active',
      builder: (tokens) => SizedBox(
        width: 160,
        height: 100,
        child: MosaicSurface(
          active: true,
          padding: EdgeInsets.all(tokens.spacing.md),
          child: Text(
            'active',
            style: tokens.typography.tileTitle.copyWith(
              color: tokens.color.textPrimary,
            ),
          ),
        ),
      ),
    );
  });
}
