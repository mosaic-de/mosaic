import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

Widget _wrap(Widget child) {
  return MosaicApp(
    motionScale: 0,
    builder: (context) => MosaicSurfaceHost(
      body: Center(child: SizedBox(width: 320, child: child)),
    ),
  );
}

void main() {
  testWidgets('shows placeholder when value is null', (tester) async {
    await tester.pumpWidget(
      _wrap(
        MosaicSelect<String>(
          value: null,
          options: const [
            MosaicSelectOption(value: 'a', label: 'Alpha'),
            MosaicSelectOption(value: 'b', label: 'Beta'),
          ],
          onChanged: (_) {},
          placeholder: 'Pick one',
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Pick one'), findsOneWidget);
  });

  testWidgets('shows selected option label', (tester) async {
    await tester.pumpWidget(
      _wrap(
        MosaicSelect<String>(
          value: 'b',
          options: const [
            MosaicSelectOption(value: 'a', label: 'Alpha'),
            MosaicSelectOption(value: 'b', label: 'Beta'),
          ],
          onChanged: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Beta'), findsOneWidget);
  });

  testWidgets('tapping pushes a panel; picking fires onChanged and pops', (
    tester,
  ) async {
    String? captured;
    await tester.pumpWidget(
      _wrap(
        MosaicSelect<String>(
          value: 'a',
          options: const [
            MosaicSelectOption(value: 'a', label: 'Alpha'),
            MosaicSelectOption(value: 'b', label: 'Beta'),
          ],
          onChanged: (v) => captured = v,
          title: 'Letters',
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Alpha').first);
    await tester.pumpAndSettle();
    // The panel header is now visible.
    expect(find.text('Letters'), findsOneWidget);

    await tester.tap(find.text('Beta'));
    await tester.pumpAndSettle();

    expect(captured, 'b');
    // Panel collapsed, header gone.
    expect(find.text('Letters'), findsNothing);
  });
}
