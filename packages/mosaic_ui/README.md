# mosaic_ui

Flutter component library for the Mosaic design system.

## Status

Phase A — tokens, mode, theme. The package builds and tests pass; no UI
components are exposed yet beyond the theme primitive.

## Phase Order

1. Tokens, mode, theme  (current)
2. Surface, press feedback
3. State primitives (`DataState<T>`, `MosaicLiveSource<T>`)
4. Tile, live tile, grid
5. Motion primitives (state switcher, expand transition, pivot)
6. Surface expansion stack, command bar

See [`docs/01-foundation/state-and-transitions.md`](../../docs/01-foundation/state-and-transitions.md)
for the architecture contract.

## Quick Look

```dart
import 'package:flutter/widgets.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MosaicTheme(
      tokens: MosaicTokens.metro(),
      child: Builder(
        builder: (context) {
          final tokens = MosaicTheme.of(context);
          return ColoredBox(color: tokens.color.background);
        },
      ),
    );
  }
}
```
