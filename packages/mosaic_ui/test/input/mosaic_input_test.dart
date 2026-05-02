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
  testWidgets('placeholder visible when empty', (tester) async {
    await tester.pumpWidget(_wrap(const MosaicInput(placeholder: 'Search')));
    await tester.pumpAndSettle();
    expect(find.text('Search'), findsOneWidget);
  });

  testWidgets('typing fires onChanged and hides placeholder', (tester) async {
    var lastValue = '';
    await tester.pumpWidget(
      _wrap(
        MosaicInput(placeholder: 'Search', onChanged: (v) => lastValue = v),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), 'java');
    await tester.pumpAndSettle();
    expect(lastValue, 'java');
    expect(find.text('Search'), findsNothing);
  });

  testWidgets('controller value seeds the field', (tester) async {
    final controller = TextEditingController(text: 'hello');
    addTearDown(controller.dispose);
    await tester.pumpWidget(_wrap(MosaicInput(controller: controller)));
    await tester.pumpAndSettle();
    expect(find.text('hello'), findsOneWidget);
  });

  testWidgets('disabled blocks editing', (tester) async {
    var changes = 0;
    await tester.pumpWidget(
      _wrap(MosaicInput(enabled: false, onChanged: (_) => changes++)),
    );
    await tester.pumpAndSettle();
    final field = find.byType(EditableText);
    expect((tester.widget(field) as EditableText).readOnly, isTrue);
    expect(changes, 0);
  });

  testWidgets('MosaicSearchInput shows the search glyph', (tester) async {
    await tester.pumpWidget(_wrap(const MosaicSearchInput()));
    await tester.pumpAndSettle();
    expect(find.text('⌕'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
  });
}
