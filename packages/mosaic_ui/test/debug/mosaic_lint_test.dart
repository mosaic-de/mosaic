import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

Widget _wrap(Widget child) => MosaicTheme.test(
      child: Directionality(textDirection: TextDirection.ltr, child: child),
    );

void main() {
  testWidgets('lint banner renders mode and brightness', (tester) async {
    await tester.pumpWidget(_wrap(
      const MosaicLint(child: SizedBox(width: 100, height: 100)),
    ));
    expect(find.textContaining('mosaic.lint'), findsOneWidget);
    expect(find.textContaining('metro'), findsOneWidget);
  });

  testWidgets('disabled lint is a passthrough', (tester) async {
    await tester.pumpWidget(_wrap(
      const MosaicLint(
        enabled: false,
        child: SizedBox(width: 100, height: 100),
      ),
    ));
    expect(find.textContaining('mosaic.lint'), findsNothing);
  });

  testWidgets('lint without theme is a passthrough', (tester) async {
    await tester.pumpWidget(const Directionality(
      textDirection: TextDirection.ltr,
      child: MosaicLint(child: SizedBox(width: 100, height: 100)),
    ));
    expect(find.textContaining('mosaic.lint'), findsNothing);
  });

  group('MosaicLintChecks', () {
    test('isTokenColor accepts a token color', () {
      final tokens = MosaicTokens.metro();
      expect(
        MosaicLintChecks.isTokenColor(tokens.color.accent, tokens),
        isTrue,
      );
    });

    test('isTokenColor rejects a hardcoded color', () {
      final tokens = MosaicTokens.metro();
      expect(
        MosaicLintChecks.isTokenColor(const Color(0xFF112233), tokens),
        isFalse,
      );
    });

    test('isTokenRadius accepts token radii and zero', () {
      final tokens = MosaicTokens.modern();
      expect(MosaicLintChecks.isTokenRadius(0, tokens), isTrue);
      expect(
        MosaicLintChecks.isTokenRadius(tokens.radius.tile.toDouble(), tokens),
        isTrue,
      );
      expect(MosaicLintChecks.isTokenRadius(7, tokens), isFalse);
    });
  });
}
