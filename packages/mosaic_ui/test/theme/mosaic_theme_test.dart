import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

class _TokenProbe extends StatelessWidget {
  const _TokenProbe({required this.onBuild});

  final void Function(MosaicTokens tokens) onBuild;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    onBuild(tokens);
    return const SizedBox.shrink();
  }
}

void main() {
  testWidgets('MosaicTheme.of exposes tokens to descendants', (tester) async {
    MosaicTokens? captured;
    await tester.pumpWidget(
      MosaicTheme.test(child: _TokenProbe(onBuild: (t) => captured = t)),
    );
    expect(captured, isNotNull);
    expect(captured!.isMetro, isTrue);
  });

  testWidgets('MosaicTheme.maybeOf returns null when no theme is present', (
    tester,
  ) async {
    MosaicTokens? captured;
    await tester.pumpWidget(
      Builder(
        builder: (context) {
          captured = MosaicTheme.maybeOf(context);
          return const SizedBox.shrink();
        },
      ),
    );
    expect(captured, isNull);
  });

  testWidgets('changing tokens rebuilds descendants', (tester) async {
    final builds = <MosaicMode>[];
    Widget app(MosaicTokens tokens) => MosaicTheme(
      tokens: tokens,
      child: _TokenProbe(onBuild: (t) => builds.add(t.mode)),
    );

    await tester.pumpWidget(app(MosaicTokens.metro(motionScale: 0)));
    await tester.pumpWidget(app(MosaicTokens.modern(motionScale: 0)));

    expect(builds, [MosaicMode.metro, MosaicMode.modern]);
  });

  test('updateShouldNotify is false for equal tokens', () {
    final a = MosaicTheme(
      tokens: MosaicTokens.metro(motionScale: 0),
      child: const SizedBox.shrink(),
    );
    final b = MosaicTheme(
      tokens: MosaicTokens.metro(motionScale: 0),
      child: const SizedBox.shrink(),
    );
    expect(a.updateShouldNotify(b), isFalse);
  });

  test('updateShouldNotify is true when tokens differ', () {
    final a = MosaicTheme(
      tokens: MosaicTokens.metro(motionScale: 0),
      child: const SizedBox.shrink(),
    );
    final b = MosaicTheme(
      tokens: MosaicTokens.modern(motionScale: 0),
      child: const SizedBox.shrink(),
    );
    expect(a.updateShouldNotify(b), isTrue);
  });

  testWidgets('test factory respects mode and brightness', (tester) async {
    MosaicTokens? captured;
    await tester.pumpWidget(
      MosaicTheme.test(
        mode: MosaicMode.modern,
        brightness: Brightness.light,
        child: _TokenProbe(onBuild: (t) => captured = t),
      ),
    );
    expect(captured!.isModern, isTrue);
    expect(captured!.isLight, isTrue);
  });

  testWidgets('test factory defaults to motionScale 0', (tester) async {
    MosaicTokens? captured;
    await tester.pumpWidget(
      MosaicTheme.test(child: _TokenProbe(onBuild: (t) => captured = t)),
    );
    expect(captured!.motion.scale, 0);
    expect(captured!.motion.scaledExpand, Duration.zero);
  });
}
