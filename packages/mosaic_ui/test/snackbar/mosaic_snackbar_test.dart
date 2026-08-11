import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

Widget _wrap(Widget child) => MosaicTheme.test(
  child: Directionality(
    textDirection: TextDirection.ltr,
    child: MosaicSnackbarHost(child: child),
  ),
);

void main() {
  testWidgets('show renders the message and dismisses after duration', (
    tester,
  ) async {
    late BuildContext captured;
    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (ctx) {
            captured = ctx;
            return const SizedBox.expand();
          },
        ),
      ),
    );

    MosaicSnackbarScope.of(
      captured,
    ).show('Saved', duration: const Duration(milliseconds: 200));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Saved'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();
    expect(find.text('Saved'), findsNothing);
  });

  testWidgets('action button fires callback and dismisses', (tester) async {
    var pressed = false;
    late BuildContext captured;
    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (ctx) {
            captured = ctx;
            return const SizedBox.expand();
          },
        ),
      ),
    );

    MosaicSnackbarScope.of(captured).show(
      'Removed',
      actionLabel: 'Undo',
      onAction: () => pressed = true,
      duration: const Duration(seconds: 5),
    );
    await tester.pumpAndSettle();
    expect(find.text('Undo'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(pressed, isTrue);
  });
}
