@Tags(<String>['golden'])
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

import '_harness.dart';

// We render the panel content directly (not pushed via show) so the
// golden captures the layout deterministically without animations.
class _StepPreview extends StatelessWidget {
  const _StepPreview({required this.step});

  final MosaicWalkthroughStep step;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    return Padding(
      padding: EdgeInsets.all(tokens.spacing.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (step.glyph != null) ...[
            Text(
              step.glyph!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 96,
                color: tokens.color.accent,
                height: 1,
              ),
            ),
            SizedBox(height: tokens.spacing.lg),
          ],
          Text(
            step.title,
            textAlign: TextAlign.center,
            style: tokens.typography.headline.copyWith(
              color: tokens.color.textPrimary,
            ),
          ),
          SizedBox(height: tokens.spacing.md),
          Text(
            step.body,
            textAlign: TextAlign.center,
            style: tokens.typography.body.copyWith(
              color: tokens.color.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  testWidgets('walkthrough step preview', (tester) async {
    await runGoldenMatrix(
      tester,
      name: 'walkthrough_step',
      size: const Size(360, 480),
      builder: (tokens) => const SizedBox(
        width: 320,
        height: 440,
        child: MosaicPanel(
          child: _StepPreview(
            step: MosaicWalkthroughStep(
              title: 'Welcome to Mosaic',
              body: 'Tiles, surfaces, and shallow journeys. Swipe to learn more.',
              glyph: '◫',
            ),
          ),
        ),
      ),
    );
  });
}
