import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

Widget _wrap(Widget child, {Brightness brightness = Brightness.dark}) {
  return MosaicTheme.test(
    brightness: brightness,
    child: Directionality(textDirection: TextDirection.ltr, child: child),
  );
}

void main() {
  testWidgets('renders the text', (tester) async {
    await tester.pumpWidget(_wrap(const MosaicText('hello')));
    expect(find.text('hello'), findsOneWidget);
  });

  testWidgets('body variant uses body typography', (tester) async {
    await tester.pumpWidget(_wrap(const MosaicText.body('row')));
    final txt = tester.widget<Text>(find.text('row'));
    final tokens = MosaicTokens.metro();
    expect(txt.style!.fontSize, tokens.typography.body.fontSize);
  });

  testWidgets('display constructor maps to display typography', (tester) async {
    await tester.pumpWidget(_wrap(const MosaicText.display('big')));
    final txt = tester.widget<Text>(find.text('big'));
    final tokens = MosaicTokens.metro();
    expect(txt.style!.fontSize, tokens.typography.display.fontSize);
  });

  testWidgets('tone resolves to a token color', (tester) async {
    await tester.pumpWidget(
      _wrap(const MosaicText('warn', tone: MosaicTextTone.error)),
    );
    final txt = tester.widget<Text>(find.text('warn'));
    final tokens = MosaicTokens.metro();
    expect(txt.style!.color, tokens.color.error);
  });

  testWidgets('explicit color beats tone', (tester) async {
    const override = Color(0xFF123456);
    await tester.pumpWidget(
      _wrap(
        const MosaicText(
          'override',
          tone: MosaicTextTone.error,
          color: override,
        ),
      ),
    );
    final txt = tester.widget<Text>(find.text('override'));
    expect(txt.style!.color, override);
  });

  testWidgets('caption defaults to secondary tone', (tester) async {
    await tester.pumpWidget(_wrap(const MosaicText.caption('cap')));
    final txt = tester.widget<Text>(find.text('cap'));
    final tokens = MosaicTokens.metro();
    expect(txt.style!.color, tokens.color.textSecondary);
  });
}
