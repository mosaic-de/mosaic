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

const _options = <MosaicSelectOption<String>>[
  MosaicSelectOption(value: 'us', label: 'United States'),
  MosaicSelectOption(value: 'uk', label: 'United Kingdom'),
  MosaicSelectOption(value: 'ke', label: 'Kenya'),
  MosaicSelectOption(value: 'sg', label: 'Singapore'),
];

void main() {
  testWidgets('shows placeholder when value is null', (tester) async {
    await tester.pumpWidget(_wrap(MosaicSearchableSelect<String>(
      value: null,
      options: _options,
      onChanged: (_) {},
      placeholder: 'Pick a country',
    )));
    await tester.pumpAndSettle();
    expect(find.text('Pick a country'), findsOneWidget);
  });

  testWidgets('opens panel; typing filters list; selecting fires onChanged',
      (tester) async {
    String? picked;
    await tester.pumpWidget(_wrap(MosaicSearchableSelect<String>(
      value: null,
      options: _options,
      onChanged: (v) => picked = v,
      title: 'Country',
    )));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(MosaicSearchableSelect<String>));
    await tester.pumpAndSettle();

    expect(find.text('Country'), findsOneWidget);
    expect(find.text('United States'), findsOneWidget);
    expect(find.text('Kenya'), findsOneWidget);

    await tester.enterText(find.byType(MosaicSearchInput), 'ken');
    await tester.pumpAndSettle();

    expect(find.text('Kenya'), findsOneWidget);
    expect(find.text('United States'), findsNothing);

    await tester.tap(find.text('Kenya'));
    await tester.pumpAndSettle();
    expect(picked, 'ke');
    expect(find.text('Country'), findsNothing);
  });

  testWidgets('empty state shows when no options match', (tester) async {
    await tester.pumpWidget(_wrap(MosaicSearchableSelect<String>(
      value: null,
      options: _options,
      onChanged: (_) {},
    )));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(MosaicSearchableSelect<String>));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(MosaicSearchInput), 'zz');
    await tester.pumpAndSettle();

    expect(find.text('No matches'), findsOneWidget);
  });
}
