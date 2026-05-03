@Tags(<String>['golden'])
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

import '_harness.dart';

void main() {
  testWidgets('button kinds', (tester) async {
    await runGoldenMatrix(
      tester,
      name: 'button_kinds',
      size: const Size(360, 240),
      builder: (tokens) => SizedBox(
        width: 280,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MosaicButton(label: 'Send', onPressed: () {}),
            SizedBox(height: tokens.spacing.sm),
            MosaicButton(
              label: 'Cancel',
              kind: MosaicButtonKind.secondary,
              onPressed: () {},
            ),
            SizedBox(height: tokens.spacing.sm),
            MosaicButton(
              label: 'Skip',
              kind: MosaicButtonKind.ghost,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  });

  testWidgets('notification kinds', (tester) async {
    await runGoldenMatrix(
      tester,
      name: 'notification_kinds',
      size: const Size(420, 480),
      builder: (tokens) => SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const MosaicNotificationCard(
              title: 'Update available',
              body: 'Restart to apply the latest changes.',
            ),
            SizedBox(height: tokens.spacing.sm),
            const MosaicNotificationCard(
              title: 'Saved',
              kind: MosaicNotificationKind.success,
            ),
            SizedBox(height: tokens.spacing.sm),
            const MosaicNotificationCard(
              title: 'Approaching daily limit',
              body: '92% of KES 5,000 used',
              kind: MosaicNotificationKind.warning,
            ),
            SizedBox(height: tokens.spacing.sm),
            const MosaicNotificationCard(
              title: 'Could not connect',
              body: 'Check your network and retry.',
              kind: MosaicNotificationKind.error,
            ),
          ],
        ),
      ),
    );
  });
}
