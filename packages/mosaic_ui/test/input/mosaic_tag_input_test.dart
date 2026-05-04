import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

Widget _wrap(Widget child) {
  return MosaicApp(
    motionScale: 0,
    builder: (context) => Center(child: SizedBox(width: 320, child: child)),
  );
}

void main() {
  testWidgets('renders existing tags', (tester) async {
    await tester.pumpWidget(
      _wrap(
        MosaicTagInput(tags: const ['flutter', 'design'], onChanged: (_) {}),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('flutter'), findsOneWidget);
    expect(find.text('design'), findsOneWidget);
  });

  testWidgets('submitting text adds a tag', (tester) async {
    List<String>? captured;
    await tester.pumpWidget(
      _wrap(
        MosaicTagInput(tags: const ['one'], onChanged: (v) => captured = v),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(MosaicTagInput));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), 'two');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(captured, ['one', 'two']);
  });

  testWidgets('tapping the × on a tag removes it', (tester) async {
    List<String>? captured;
    await tester.pumpWidget(
      _wrap(
        MosaicTagInput(
          tags: const ['flutter', 'design'],
          onChanged: (v) => captured = v,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('×').first);
    await tester.pumpAndSettle();
    expect(captured, ['design']);
  });

  testWidgets('duplicates rejected by default', (tester) async {
    List<String>? captured;
    await tester.pumpWidget(
      _wrap(
        MosaicTagInput(tags: const ['flutter'], onChanged: (v) => captured = v),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(MosaicTagInput));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), 'flutter');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(captured, isNull);
  });
}
