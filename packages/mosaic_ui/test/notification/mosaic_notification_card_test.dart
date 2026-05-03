import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

Widget _wrap(Widget child) {
  return MosaicTheme.test(
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Center(child: SizedBox(width: 320, child: child)),
    ),
  );
}

void main() {
  testWidgets('renders title and body', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const MosaicNotificationCard(
          title: 'Heads up',
          body: 'Something happened',
        ),
      ),
    );
    expect(find.text('Heads up'), findsOneWidget);
    expect(find.text('Something happened'), findsOneWidget);
  });

  testWidgets('default glyph maps to kind', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const MosaicNotificationCard(
          title: 'Saved',
          kind: MosaicNotificationKind.success,
        ),
      ),
    );
    expect(find.text('✓'), findsOneWidget);
  });

  testWidgets('custom glyph wins over kind default', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const MosaicNotificationCard(
          title: 'Custom',
          glyph: '★',
          kind: MosaicNotificationKind.info,
        ),
      ),
    );
    expect(find.text('★'), findsOneWidget);
  });

  testWidgets('dismiss fires onDismiss', (tester) async {
    var dismissed = false;
    await tester.pumpWidget(
      _wrap(
        MosaicNotificationCard(
          title: 'Hello',
          onDismiss: () => dismissed = true,
        ),
      ),
    );
    await tester.tap(find.text('×'));
    await tester.pumpAndSettle();
    expect(dismissed, isTrue);
  });

  testWidgets('action slot renders', (tester) async {
    await tester.pumpWidget(
      _wrap(
        MosaicNotificationCard(
          title: 'Update available',
          action: MosaicButton(
            label: 'Install',
            kind: MosaicButtonKind.ghost,
            onPressed: () {},
          ),
        ),
      ),
    );
    expect(find.text('Install'), findsOneWidget);
  });
}
