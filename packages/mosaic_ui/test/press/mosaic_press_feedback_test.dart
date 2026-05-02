import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

void main() {
  testWidgets('onPressed fires on tap', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MosaicTheme.test(
        child: Center(
          child: MosaicPressFeedback(
            onPressed: () => taps++,
            child: const SizedBox(width: 80, height: 80),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(MosaicPressFeedback));
    await tester.pumpAndSettle();
    expect(taps, 1);
  });

  testWidgets('onLongPress fires on long press', (tester) async {
    var longPresses = 0;
    await tester.pumpWidget(
      MosaicTheme.test(
        child: Center(
          child: MosaicPressFeedback(
            onLongPress: () => longPresses++,
            child: const SizedBox(width: 80, height: 80),
          ),
        ),
      ),
    );
    await tester.longPress(find.byType(MosaicPressFeedback));
    await tester.pumpAndSettle();
    expect(longPresses, 1);
  });

  testWidgets('disabled blocks tap callback', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MosaicTheme.test(
        child: Center(
          child: MosaicPressFeedback(
            onPressed: () => taps++,
            enabled: false,
            child: const SizedBox(width: 80, height: 80),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(MosaicPressFeedback), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(taps, 0);
  });

  testWidgets('non-interactive (no callbacks) renders the child untouched', (
    tester,
  ) async {
    await tester.pumpWidget(
      MosaicTheme.test(
        child: const Center(
          child: MosaicPressFeedback(
            child: SizedBox(width: 80, height: 80, key: Key('child')),
          ),
        ),
      ),
    );
    expect(find.byKey(const Key('child')), findsOneWidget);
    expect(find.byType(GestureDetector), findsNothing);
    expect(find.byType(MouseRegion), findsNothing);
  });

  testWidgets('Modern mode applies 0.98 scale on press', (tester) async {
    await tester.pumpWidget(
      MosaicTheme.test(
        mode: MosaicMode.modern,
        child: Center(
          child: MosaicPressFeedback(
            onPressed: () {},
            child: const SizedBox(width: 80, height: 80),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(MosaicPressFeedback)),
    );
    await tester.pumpAndSettle();

    final scaleWidget = tester.widget<AnimatedScale>(
      find.byType(AnimatedScale),
    );
    expect(scaleWidget.scale, 0.98);

    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('Metro mode does not scale on press', (tester) async {
    await tester.pumpWidget(
      MosaicTheme.test(
        child: Center(
          child: MosaicPressFeedback(
            onPressed: () {},
            child: const SizedBox(width: 80, height: 80),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(MosaicPressFeedback)),
    );
    await tester.pumpAndSettle();

    final scaleWidget = tester.widget<AnimatedScale>(
      find.byType(AnimatedScale),
    );
    expect(scaleWidget.scale, 1.0);

    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('disabled drops opacity', (tester) async {
    await tester.pumpWidget(
      MosaicTheme.test(
        child: Center(
          child: MosaicPressFeedback(
            onPressed: () {},
            enabled: false,
            child: const SizedBox(width: 80, height: 80),
          ),
        ),
      ),
    );
    final opacity = tester.widget<AnimatedOpacity>(
      find.byType(AnimatedOpacity),
    );
    expect(opacity.opacity, lessThan(1.0));
  });
}
