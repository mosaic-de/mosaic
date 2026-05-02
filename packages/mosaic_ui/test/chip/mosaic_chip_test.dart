import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

Widget _wrap(Widget child) {
  return MosaicTheme.test(
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Center(child: child),
    ),
  );
}

void main() {
  testWidgets('renders label', (tester) async {
    await tester.pumpWidget(
      _wrap(MosaicChip(label: 'Income', selected: false, onPressed: () {})),
    );
    expect(find.text('Income'), findsOneWidget);
  });

  testWidgets('fires onPressed', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(
        MosaicChip(label: 'Income', selected: false, onPressed: () => taps++),
      ),
    );
    await tester.tap(find.text('Income'));
    await tester.pumpAndSettle();
    expect(taps, 1);
  });

  testWidgets('selected paints accent fill', (tester) async {
    await tester.pumpWidget(
      _wrap(MosaicChip(label: 'On', selected: true, onPressed: () {})),
    );
    final ac = tester.widget<AnimatedContainer>(
      find.byKey(const ValueKey<String>('mosaic.chip.surface')),
    );
    final tokens = MosaicTokens.metro(motionScale: 0);
    final decoration = ac.decoration! as BoxDecoration;
    expect(decoration.color, tokens.color.accent);
    expect(decoration.border, isA<Border>());
  });

  testWidgets('idle is hollow with a divider-color border', (tester) async {
    await tester.pumpWidget(
      _wrap(MosaicChip(label: 'Off', selected: false, onPressed: () {})),
    );
    final ac = tester.widget<AnimatedContainer>(
      find.byKey(const ValueKey<String>('mosaic.chip.surface')),
    );
    final tokens = MosaicTokens.metro(motionScale: 0);
    final decoration = ac.decoration! as BoxDecoration;
    expect(decoration.color, const Color(0x00000000));
    final border = decoration.border! as Border;
    expect(border.top.color, tokens.color.divider);
  });
}
