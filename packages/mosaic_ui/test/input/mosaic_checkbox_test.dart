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
  testWidgets('renders label', (tester) async {
    await tester.pumpWidget(
      _wrap(
        MosaicCheckbox(value: false, onChanged: (_) {}, label: 'Subscribe'),
      ),
    );
    expect(find.text('Subscribe'), findsOneWidget);
  });

  testWidgets('toggles on tap and reports new value', (tester) async {
    bool? lastValue;
    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) {
            return MosaicCheckbox(
              value: lastValue ?? false,
              label: 'Subscribe',
              onChanged: (v) => setState(() => lastValue = v),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('Subscribe'));
    await tester.pumpAndSettle();
    expect(lastValue, isTrue);
    await tester.tap(find.text('Subscribe'));
    await tester.pumpAndSettle();
    expect(lastValue, isFalse);
  });

  testWidgets('shows checkmark when value is true', (tester) async {
    await tester.pumpWidget(
      _wrap(MosaicCheckbox(value: true, onChanged: (_) {})),
    );
    expect(find.text('✓'), findsOneWidget);
  });

  testWidgets('disabled blocks toggle', (tester) async {
    var changes = 0;
    await tester.pumpWidget(
      _wrap(
        MosaicCheckbox(
          value: false,
          enabled: false,
          onChanged: (_) => changes++,
          label: 'Disabled',
        ),
      ),
    );
    await tester.tap(find.text('Disabled'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(changes, 0);
  });
}
