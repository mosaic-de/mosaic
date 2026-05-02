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
  testWidgets('renders one button per command', (tester) async {
    await tester.pumpWidget(
      _wrap(
        MosaicCommandBar(
          commands: [
            MosaicCommand(label: 'A', onPressed: () {}),
            MosaicCommand(label: 'B', onPressed: () {}),
            MosaicCommand(label: 'C', onPressed: () {}),
          ],
        ),
      ),
    );

    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
    expect(find.text('C'), findsOneWidget);
  });

  testWidgets('fires onPressed for the tapped command', (tester) async {
    var aTaps = 0;
    var bTaps = 0;
    await tester.pumpWidget(
      _wrap(
        MosaicCommandBar(
          commands: [
            MosaicCommand(label: 'A', onPressed: () => aTaps++),
            MosaicCommand(label: 'B', onPressed: () => bTaps++),
          ],
        ),
      ),
    );

    await tester.tap(find.text('B'));
    await tester.pumpAndSettle();
    expect(aTaps, 0);
    expect(bTaps, 1);
  });

  testWidgets('disabled command does not fire', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(
        MosaicCommandBar(
          commands: [
            MosaicCommand(label: 'A', enabled: false, onPressed: () => taps++),
          ],
        ),
      ),
    );
    await tester.tap(find.text('A'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(taps, 0);
  });
}
