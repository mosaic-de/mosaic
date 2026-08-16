import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

BoxDecoration _decoration(WidgetTester tester) {
  final container = tester.widget<Container>(find.byType(Container));
  return container.decoration! as BoxDecoration;
}

void main() {
  group('aurora glass', () {
    testWidgets('takes the backdrop path, which the opaque modes do not', (
      tester,
    ) async {
      for (final mode in MosaicMode.values) {
        await tester.pumpWidget(
          MosaicTheme.test(
            mode: mode,
            child: const MosaicSurface(
              kind: MosaicSurfaceKind.tile,
              child: SizedBox(width: 64, height: 64),
            ),
          ),
        );
        final filters = find.byType(BackdropFilter);
        if (mode == MosaicMode.aurora) {
          expect(filters, findsOneWidget, reason: '$mode should blur');
        } else {
          // The cheap path matters: a BackdropFilter per tile across a
          // full grid is not free, and metro/modern have nothing to
          // blur behind an opaque fill anyway.
          expect(filters, findsNothing, reason: '$mode must not blur');
        }
      }
    });

    testWidgets('is clipped, or the blur bleeds past its corners', (
      tester,
    ) async {
      await tester.pumpWidget(
        MosaicTheme.test(
          mode: MosaicMode.aurora,
          child: const MosaicSurface(
            kind: MosaicSurfaceKind.tile,
            child: SizedBox(width: 64, height: 64),
          ),
        ),
      );
      expect(find.byType(ClipRRect), findsWidgets);
    });

    testWidgets('lights the top edge with a falling-off gradient', (
      tester,
    ) async {
      await tester.pumpWidget(
        MosaicTheme.test(
          mode: MosaicMode.aurora,
          child: const MosaicSurface(
            kind: MosaicSurfaceKind.tile,
            child: SizedBox(width: 64, height: 64),
          ),
        ),
      );
      final gradients = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .map((box) => box.decoration)
          .whereType<BoxDecoration>()
          .map((decoration) => decoration.gradient)
          .whereType<LinearGradient>();

      expect(gradients, isNotEmpty, reason: 'sheen gradient missing');
      final sheen = gradients.first;
      expect(sheen.begin, Alignment.topCenter);
      // Brightest at the top and gone well before the bottom — a sheen
      // that reaches halfway reads as a gradient fill, not reflection.
      expect(sheen.colors.first.a, greaterThan(sheen.colors.last.a));
      expect(sheen.stops!.last, lessThan(0.6));
    });

    testWidgets('renders opaque fills without a sheen', (tester) async {
      await tester.pumpWidget(
        MosaicTheme.test(
          child: const MosaicSurface(
            kind: MosaicSurfaceKind.tile,
            child: SizedBox(width: 64, height: 64),
          ),
        ),
      );
      final gradients = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .map((box) => box.decoration)
          .whereType<BoxDecoration>()
          .where((decoration) => decoration.gradient != null);
      expect(gradients, isEmpty);
    });
  });

  testWidgets('Metro tile surface renders with zero shadow', (tester) async {
    await tester.pumpWidget(
      MosaicTheme.test(
        child: const MosaicSurface(
          kind: MosaicSurfaceKind.tile,
          child: SizedBox(width: 64, height: 64),
        ),
      ),
    );
    expect(_decoration(tester).boxShadow, isNull);
  });

  testWidgets('Modern tile surface renders subtle shadow', (tester) async {
    await tester.pumpWidget(
      MosaicTheme.test(
        mode: MosaicMode.modern,
        child: const MosaicSurface(
          kind: MosaicSurfaceKind.tile,
          child: SizedBox(width: 64, height: 64),
        ),
      ),
    );
    final shadows = _decoration(tester).boxShadow;
    expect(shadows, isNotNull);
    expect(shadows!.length, 1);
    expect(shadows.first.blurRadius, lessThanOrEqualTo(16));
  });

  testWidgets('active surface uses surfaceActive color', (tester) async {
    await tester.pumpWidget(
      MosaicTheme.test(
        child: const MosaicSurface(
          active: true,
          child: SizedBox(width: 64, height: 64),
        ),
      ),
    );
    final tokens = MosaicTokens.metro(motionScale: 0);
    expect(_decoration(tester).color, tokens.color.surfaceActive);
  });

  testWidgets(
    'muted surface uses surfaceMuted and zero radius if metro panel-style 0',
    (tester) async {
      await tester.pumpWidget(
        MosaicTheme.test(
          child: const MosaicSurface(
            kind: MosaicSurfaceKind.muted,
            child: SizedBox(width: 64, height: 64),
          ),
        ),
      );
      final tokens = MosaicTokens.metro(motionScale: 0);
      expect(_decoration(tester).color, tokens.color.surfaceMuted);
    },
  );

  testWidgets('panel surface in Metro has zero radius', (tester) async {
    await tester.pumpWidget(
      MosaicTheme.test(
        child: const MosaicSurface(
          kind: MosaicSurfaceKind.panel,
          child: SizedBox(width: 64, height: 64),
        ),
      ),
    );
    expect(_decoration(tester).borderRadius, isNull);
  });

  testWidgets('panel surface in Modern uses panel radius', (tester) async {
    await tester.pumpWidget(
      MosaicTheme.test(
        mode: MosaicMode.modern,
        child: const MosaicSurface(
          kind: MosaicSurfaceKind.panel,
          child: SizedBox(width: 64, height: 64),
        ),
      ),
    );
    final tokens = MosaicTokens.modern(motionScale: 0);
    expect(
      _decoration(tester).borderRadius,
      BorderRadius.circular(tokens.radius.panel),
    );
  });

  testWidgets('color override beats kind default', (tester) async {
    const override = Color(0xFF123456);
    await tester.pumpWidget(
      MosaicTheme.test(
        child: const MosaicSurface(
          color: override,
          child: SizedBox(width: 64, height: 64),
        ),
      ),
    );
    expect(_decoration(tester).color, override);
  });
}
