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
  testWidgets('renders the requested number of cells', (tester) async {
    await tester.pumpWidget(_wrap(const MosaicPinInput(length: 6)));
    await tester.pumpAndSettle();
    // Each cell is a Container with a fixed width of 44.
    expect(find.byType(Container), findsNWidgets(6));
  });

  testWidgets('typing fills cells and fires onChanged', (tester) async {
    String? captured;
    await tester.pumpWidget(
      _wrap(MosaicPinInput(length: 4, onChanged: (v) => captured = v)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(MosaicPinInput));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), '1234');
    await tester.pumpAndSettle();
    expect(captured, '1234');
    expect(find.text('1'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
  });

  testWidgets('onCompleted fires at length', (tester) async {
    String? completedAt;
    await tester.pumpWidget(
      _wrap(MosaicPinInput(length: 3, onCompleted: (v) => completedAt = v)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(MosaicPinInput));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), '12');
    await tester.pumpAndSettle();
    expect(completedAt, isNull);
    await tester.enterText(find.byType(EditableText), '123');
    await tester.pumpAndSettle();
    expect(completedAt, '123');
  });

  testWidgets('obscured replaces digits with bullets', (tester) async {
    await tester.pumpWidget(
      _wrap(const MosaicPinInput(length: 3, obscured: true)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(MosaicPinInput));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), '12');
    await tester.pumpAndSettle();
    expect(find.text('•'), findsNWidgets(2));
    expect(find.text('1'), findsNothing);
  });
}
