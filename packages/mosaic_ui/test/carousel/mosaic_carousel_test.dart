import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

Widget _wrap(Widget child) {
  return MosaicTheme.test(
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Center(child: SizedBox(width: 320, height: 240, child: child)),
    ),
  );
}

void main() {
  testWidgets('renders the first item initially', (tester) async {
    await tester.pumpWidget(
      _wrap(
        MosaicCarousel(
          height: 160,
          items: [
            for (var i = 0; i < 3; i++)
              Text('item-$i', textDirection: TextDirection.ltr),
          ],
        ),
      ),
    );
    expect(find.text('item-0'), findsOneWidget);
  });

  testWidgets('builder constructor builds lazily', (tester) async {
    await tester.pumpWidget(
      _wrap(
        MosaicCarousel.builder(
          height: 160,
          itemCount: 50,
          itemBuilder: (context, i) =>
              Text('row-$i', textDirection: TextDirection.ltr),
        ),
      ),
    );
    expect(find.text('row-0'), findsOneWidget);
    expect(find.text('row-49'), findsNothing);
  });

  testWidgets('initialIndex respected', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const MosaicCarousel(
          height: 160,
          initialIndex: 1,
          viewportFraction: 1.0,
          items: [
            Text('a', textDirection: TextDirection.ltr),
            Text('b', textDirection: TextDirection.ltr),
            Text('c', textDirection: TextDirection.ltr),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('b'), findsOneWidget);
  });

  testWidgets('hides indicator when showIndicator is false', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const MosaicCarousel(
          height: 160,
          showIndicator: false,
          items: [Text('one', textDirection: TextDirection.ltr)],
        ),
      ),
    );
    expect(find.byType(AnimatedContainer), findsNothing);
  });
}
