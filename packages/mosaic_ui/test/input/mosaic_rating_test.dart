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
  testWidgets('renders count glyphs', (tester) async {
    await tester.pumpWidget(_wrap(MosaicRating(value: 3, onChanged: (_) {})));
    expect(find.text('★'), findsNWidgets(3));
    expect(find.text('☆'), findsNWidgets(2));
  });

  testWidgets('tap fires onChanged with index', (tester) async {
    int? captured;
    await tester.pumpWidget(
      _wrap(MosaicRating(value: 0, onChanged: (v) => captured = v)),
    );
    final stars = find.text('☆');
    await tester.tap(stars.at(2));
    await tester.pumpAndSettle();
    expect(captured, 3);
  });

  testWidgets('respects custom count + glyphs', (tester) async {
    await tester.pumpWidget(
      _wrap(
        MosaicRating(
          value: 2,
          count: 3,
          glyph: '●',
          emptyGlyph: '○',
          onChanged: (_) {},
        ),
      ),
    );
    expect(find.text('●'), findsNWidgets(2));
    expect(find.text('○'), findsOneWidget);
  });

  testWidgets('disabled blocks tap', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      _wrap(MosaicRating(value: 0, enabled: false, onChanged: (_) => calls++)),
    );
    await tester.tap(find.text('☆').first, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(calls, 0);
  });
}
