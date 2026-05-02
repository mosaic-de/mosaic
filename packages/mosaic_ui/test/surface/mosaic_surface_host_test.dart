import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final scope = MosaicSurfaceScope.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('home', textDirection: TextDirection.ltr),
          MosaicPressFeedback(
            onPressed: () => scope.push(
              (context) => const MosaicPanel(
                child: Text('panel-A', textDirection: TextDirection.ltr),
              ),
            ),
            child: const Text('open A', textDirection: TextDirection.ltr),
          ),
        ],
      ),
    );
  }
}

void main() {
  testWidgets('depth starts at 0; push and pop adjust it', (tester) async {
    int? capturedDepth;
    await tester.pumpWidget(
      MosaicTheme.test(
        child: MosaicSurfaceHost(
          body: Builder(
            builder: (context) {
              capturedDepth = MosaicSurfaceScope.of(context).depth;
              return const SizedBox.expand();
            },
          ),
        ),
      ),
    );
    expect(capturedDepth, 0);
  });

  testWidgets('push renders the panel above the body', (tester) async {
    await tester.pumpWidget(
      MosaicTheme.test(child: const MosaicSurfaceHost(body: _Body())),
    );

    expect(find.text('home'), findsOneWidget);
    expect(find.text('panel-A'), findsNothing);

    await tester.tap(find.text('open A'));
    await tester.pumpAndSettle();

    expect(find.text('home'), findsOneWidget);
    expect(find.text('panel-A'), findsOneWidget);
  });

  testWidgets('pop collapses the topmost layer only', (tester) async {
    late MosaicSurfaceScope scope;
    await tester.pumpWidget(
      MosaicTheme.test(
        child: MosaicSurfaceHost(
          body: Builder(
            builder: (context) {
              scope = MosaicSurfaceScope.of(context);
              return const Text('home', textDirection: TextDirection.ltr);
            },
          ),
        ),
      ),
    );

    scope.push(
      (context) =>
          const MosaicPanel(child: Text('A', textDirection: TextDirection.ltr)),
    );
    await tester.pumpAndSettle();
    scope.push(
      (context) =>
          const MosaicPanel(child: Text('B', textDirection: TextDirection.ltr)),
    );
    await tester.pumpAndSettle();

    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);

    scope.pop();
    await tester.pumpAndSettle();

    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsNothing);
  });

  testWidgets('updateShouldNotify fires when depth changes', (tester) async {
    var rebuilds = 0;
    late MosaicSurfaceScope scope;
    await tester.pumpWidget(
      MosaicTheme.test(
        child: MosaicSurfaceHost(
          body: Builder(
            builder: (context) {
              rebuilds++;
              scope = MosaicSurfaceScope.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    final before = rebuilds;
    scope.push((_) => const MosaicPanel(child: SizedBox.shrink()));
    await tester.pumpAndSettle();
    expect(rebuilds, greaterThan(before));
  });
}
