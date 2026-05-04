import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

Widget _wrap(Widget child) => MosaicTheme.test(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Center(child: SizedBox(width: 200, height: 200, child: child)),
      ),
    );

void main() {
  testWidgets('renders label and four previews', (tester) async {
    await tester.pumpWidget(_wrap(MosaicFolderTile(
      label: 'Work',
      size: MosaicTileSize.medium,
      previews: const [
        ColoredBox(color: Color(0xFFFF0000)),
        ColoredBox(color: Color(0xFF00FF00)),
        ColoredBox(color: Color(0xFF0000FF)),
        ColoredBox(color: Color(0xFFFFFF00)),
      ],
      onOpen: () {},
    )));
    expect(find.text('Work'), findsOneWidget);
  });

  testWidgets('overlay shows +N when count exceeds previews shown',
      (tester) async {
    await tester.pumpWidget(_wrap(MosaicFolderTile(
      label: 'Social',
      size: MosaicTileSize.medium,
      count: 9,
      previews: const [
        ColoredBox(color: Color(0xFFFF0000)),
        ColoredBox(color: Color(0xFF00FF00)),
      ],
      onOpen: () {},
    )));
    expect(find.text('+7'), findsOneWidget);
  });

  testWidgets('tap fires onOpen', (tester) async {
    var called = 0;
    await tester.pumpWidget(_wrap(MosaicFolderTile(
      label: 'Folder',
      size: MosaicTileSize.medium,
      previews: const [],
      onOpen: () => called += 1,
    )));
    await tester.tap(find.byType(MosaicFolderTile));
    await tester.pumpAndSettle();
    expect(called, 1);
  });
}
