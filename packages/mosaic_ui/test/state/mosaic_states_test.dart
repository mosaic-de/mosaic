import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

Widget _wrap(Widget child) => MosaicTheme.test(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox(width: 360, height: 480, child: child),
        ),
      ),
    );

void main() {
  group('MosaicEmptyState', () {
    testWidgets('renders title and body', (tester) async {
      await tester.pumpWidget(_wrap(const MosaicEmptyState(
        title: 'Nothing yet',
        body: 'Saved items will show here.',
      )));
      expect(find.text('Nothing yet'), findsOneWidget);
      expect(find.text('Saved items will show here.'), findsOneWidget);
    });

    testWidgets('action label fires the callback', (tester) async {
      var called = false;
      await tester.pumpWidget(_wrap(MosaicEmptyState(
        title: 't',
        actionLabel: 'Add',
        onAction: () => called = true,
      )));
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      expect(called, isTrue);
    });

    test('asserts that label and callback are paired', () {
      expect(
        () => MosaicEmptyState(title: 't', actionLabel: 'go'),
        throwsAssertionError,
      );
    });
  });

  group('MosaicErrorState', () {
    testWidgets('shows retry button when callback is supplied',
        (tester) async {
      var called = false;
      await tester.pumpWidget(_wrap(MosaicErrorState(
        body: 'Network failed',
        onRetry: () => called = true,
      )));
      expect(find.text('Network failed'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(called, isTrue);
    });

    testWidgets('omits retry button without callback', (tester) async {
      await tester.pumpWidget(
        _wrap(const MosaicErrorState(body: 'fail')),
      );
      expect(find.text('Retry'), findsNothing);
    });
  });

  group('MosaicInlineError', () {
    testWidgets('renders message in error tone', (tester) async {
      await tester.pumpWidget(_wrap(
        const MosaicInlineError('Required field'),
      ));
      expect(find.text('Required field'), findsOneWidget);
      final txt = tester.widget<Text>(find.text('Required field'));
      final tokens = MosaicTokens.metro();
      expect(txt.style!.color, tokens.color.error);
    });
  });
}
