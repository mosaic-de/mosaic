import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

class _Probe extends StatelessWidget {
  const _Probe({required this.onBuild});

  final void Function(MosaicTokens tokens, MosaicAppScope scope) onBuild;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    final scope = MosaicAppScope.of(context);
    onBuild(tokens, scope);
    return const SizedBox.expand();
  }
}

void main() {
  testWidgets('MosaicApp installs MosaicTheme and MosaicAppScope', (
    tester,
  ) async {
    MosaicTokens? capturedTokens;
    MosaicAppScope? capturedScope;
    await tester.pumpWidget(
      MosaicApp(
        motionScale: 0,
        builder: (context) => _Probe(
          onBuild: (t, s) {
            capturedTokens = t;
            capturedScope = s;
          },
        ),
      ),
    );
    expect(capturedTokens, isNotNull);
    expect(capturedTokens!.isMetro, isTrue);
    expect(capturedScope, isNotNull);
    expect(capturedScope!.mode, MosaicMode.metro);
    expect(capturedScope!.brightness, Brightness.dark);
  });

  testWidgets('initialMode and initialBrightness are honored', (tester) async {
    MosaicTokens? captured;
    await tester.pumpWidget(
      MosaicApp(
        motionScale: 0,
        initialMode: MosaicMode.modern,
        initialBrightness: Brightness.light,
        builder: (context) => _Probe(onBuild: (t, _) => captured = t),
      ),
    );
    expect(captured!.isModern, isTrue);
    expect(captured!.isLight, isTrue);
  });

  testWidgets('toggleMode swaps tokens and notifies', (tester) async {
    final modes = <MosaicMode>[];
    var notifications = 0;
    MosaicAppScope? scope;
    await tester.pumpWidget(
      MosaicApp(
        motionScale: 0,
        onModeChanged: (m) => notifications++,
        builder: (context) => _Probe(
          onBuild: (t, s) {
            modes.add(t.mode);
            scope = s;
          },
        ),
      ),
    );

    expect(modes.last, MosaicMode.metro);
    scope!.toggleMode();
    await tester.pump();
    expect(modes.last, MosaicMode.modern);
    expect(notifications, 1);

    scope!.toggleMode();
    await tester.pump();
    expect(modes.last, MosaicMode.metro);
    expect(notifications, 2);
  });

  testWidgets('setBrightness updates tokens', (tester) async {
    final brightnesses = <Brightness>[];
    MosaicAppScope? scope;
    await tester.pumpWidget(
      MosaicApp(
        motionScale: 0,
        builder: (context) => _Probe(
          onBuild: (t, s) {
            brightnesses.add(t.brightness);
            scope = s;
          },
        ),
      ),
    );
    expect(brightnesses.last, Brightness.dark);
    scope!.setBrightness(Brightness.light);
    await tester.pump();
    expect(brightnesses.last, Brightness.light);
  });

  testWidgets('motionScale is applied to tokens', (tester) async {
    MosaicTokens? captured;
    await tester.pumpWidget(
      MosaicApp(
        motionScale: 0,
        builder: (context) => _Probe(onBuild: (t, _) => captured = t),
      ),
    );
    expect(captured!.motion.scale, 0);
    expect(captured!.motion.scaledExpand, Duration.zero);
  });

  testWidgets('setMode to current mode is a no-op (no notification)', (
    tester,
  ) async {
    var notifications = 0;
    MosaicAppScope? scope;
    await tester.pumpWidget(
      MosaicApp(
        motionScale: 0,
        onModeChanged: (_) => notifications++,
        builder: (context) => _Probe(onBuild: (_, s) => scope = s),
      ),
    );
    scope!.setMode(MosaicMode.metro);
    await tester.pump();
    expect(notifications, 0);
  });
}
