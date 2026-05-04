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
  testWidgets('renders the registered glyph', (tester) async {
    await tester.pumpWidget(_wrap(const MosaicIcon('search')));
    expect(find.text('⌕'), findsOneWidget);
  });

  testWidgets('unknown name renders the fallback', (tester) async {
    await tester.pumpWidget(_wrap(const MosaicIcon('not.a.real.icon')));
    expect(find.text('·'), findsOneWidget);
  });

  testWidgets('color override beats token default', (tester) async {
    const override = Color(0xFF112233);
    await tester.pumpWidget(_wrap(const MosaicIcon('check', color: override)));
    final text = tester.widget<Text>(find.byType(Text));
    expect(text.style!.color, override);
  });

  testWidgets('size sets the font size', (tester) async {
    await tester.pumpWidget(_wrap(const MosaicIcon('star', size: 32)));
    final text = tester.widget<Text>(find.byType(Text));
    expect(text.style!.fontSize, 32);
  });

  test('names exposes registered icons', () {
    expect(MosaicIcon.names, contains('search'));
    expect(MosaicIcon.names, contains('star'));
    expect(MosaicIcon.names, contains('arrow.left'));
    expect(MosaicIcon.names.length, greaterThan(20));
  });
}
