import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

void main() {
  testWidgets('crossfades when child key changes', (tester) async {
    Widget build(String label) => MosaicTheme.test(
      motionScale: 1,
      child: Center(
        child: SizedBox(
          width: 100,
          height: 100,
          child: MosaicStateSwitcher(
            child: KeyedSubtree(
              key: ValueKey<String>(label),
              child: Text(label, textDirection: TextDirection.ltr),
            ),
          ),
        ),
      ),
    );

    await tester.pumpWidget(build('a'));
    expect(find.text('a'), findsOneWidget);

    await tester.pumpWidget(build('b'));
    // mid-transition, both children should be in the tree
    await tester.pump(const Duration(milliseconds: 1));
    expect(find.text('a'), findsOneWidget);
    expect(find.text('b'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('a'), findsNothing);
    expect(find.text('b'), findsOneWidget);
  });

  testWidgets('uses motion.update duration from tokens', (tester) async {
    Widget build(String label) => MosaicTheme(
      tokens: MosaicTokens.metro(),
      child: Center(
        child: MosaicStateSwitcher(
          child: KeyedSubtree(
            key: ValueKey<String>(label),
            child: Text(label, textDirection: TextDirection.ltr),
          ),
        ),
      ),
    );

    await tester.pumpWidget(build('a'));
    final switcher = tester.widget<AnimatedSwitcher>(
      find.byType(AnimatedSwitcher),
    );
    expect(switcher.duration, MosaicTokens.metro().motion.update);
  });
}
