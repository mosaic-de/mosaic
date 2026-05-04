import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

class _Host extends StatelessWidget {
  const _Host({required this.steps, this.onComplete, this.onSkip});

  final List<MosaicWalkthroughStep> steps;
  final VoidCallback? onComplete;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    return MosaicApp(
      motionScale: 0,
      builder: (context) => MosaicSurfaceHost(
        body: Center(
          child: Builder(
            builder: (context) => MosaicPressFeedback(
              onPressed: () => MosaicWalkthrough.show(
                context,
                steps: steps,
                onComplete: onComplete,
                onSkip: onSkip,
              ),
              child: const Text('open', textDirection: TextDirection.ltr),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('show pushes a panel with the first step', (tester) async {
    await tester.pumpWidget(
      const _Host(
        steps: [
          MosaicWalkthroughStep(title: 'Step one', body: 'first body'),
          MosaicWalkthroughStep(title: 'Step two', body: 'second body'),
        ],
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Step one'), findsOneWidget);
    expect(find.text('first body'), findsOneWidget);
  });

  testWidgets('Next on intermediate step advances; Done on last fires complete',
      (tester) async {
    var completed = false;
    await tester.pumpWidget(
      _Host(
        onComplete: () => completed = true,
        steps: const [
          MosaicWalkthroughStep(title: 'A', body: 'a'),
          MosaicWalkthroughStep(title: 'B', body: 'b'),
        ],
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // Step 1: button reads "Next".
    expect(find.text('Next'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Step 2: button reads "Done".
    expect(find.text('Done'), findsOneWidget);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(completed, isTrue);
    // Panel collapsed.
    expect(find.text('A'), findsNothing);
  });

  testWidgets('Skip on intermediate step fires onSkip and pops',
      (tester) async {
    var skipped = false;
    await tester.pumpWidget(
      _Host(
        onSkip: () => skipped = true,
        steps: const [
          MosaicWalkthroughStep(title: 'A', body: 'a'),
          MosaicWalkthroughStep(title: 'B', body: 'b'),
          MosaicWalkthroughStep(title: 'C', body: 'c'),
        ],
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Skip'), findsOneWidget);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(skipped, isTrue);
    expect(find.text('A'), findsNothing);
  });

  testWidgets('Skip is hidden on the last step', (tester) async {
    await tester.pumpWidget(
      const _Host(
        steps: [
          MosaicWalkthroughStep(title: 'Only', body: 'only step'),
        ],
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Skip'), findsNothing);
    expect(find.text('Done'), findsOneWidget);
  });
}
