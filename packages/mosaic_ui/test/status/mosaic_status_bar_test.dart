import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

Widget _wrap(Widget child) => MosaicTheme.test(
  child: Directionality(textDirection: TextDirection.ltr, child: child),
);

void main() {
  testWidgets('renders title and caption', (tester) async {
    await tester.pumpWidget(
      _wrap(const MosaicStatusBar(title: 'Wallet', caption: 'jonny')),
    );
    expect(find.text('Wallet'), findsOneWidget);
    expect(find.text('jonny'), findsOneWidget);
  });

  testWidgets('omits caption when null', (tester) async {
    await tester.pumpWidget(_wrap(const MosaicStatusBar(title: 'Wallet')));
    expect(find.text('Wallet'), findsOneWidget);
    expect(find.byType(Text), findsOneWidget);
  });

  testWidgets('renders trailing slot', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const MosaicStatusBar(
          title: 'Hello',
          trailing: MosaicBadge(label: 'NEW'),
        ),
      ),
    );
    expect(find.text('NEW'), findsOneWidget);
  });
}
