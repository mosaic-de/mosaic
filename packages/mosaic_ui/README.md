# mosaic_ui

Flutter component library for the Mosaic design system.

## Status

Tokens, theme, and the surface + press primitives are in place. The tile
system and live data layer are next.

## Roadmap

- [x] Tokens, mode, theme
- [x] Surface, press feedback
- [ ] State primitives (`DataState<T>`, `MosaicLiveSource<T>`)
- [ ] Tile, live tile, grid
- [ ] Motion primitives (state switcher, expand transition, pivot)
- [ ] Surface expansion stack, command bar

See [`docs/01-foundation/state-and-transitions.md`](../../docs/01-foundation/state-and-transitions.md)
for the architecture contract.

## Quick Look

```dart
import 'package:flutter/widgets.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

class Demo extends StatelessWidget {
  const Demo({super.key});

  @override
  Widget build(BuildContext context) {
    return MosaicTheme(
      tokens: MosaicTokens.metro(),
      child: Center(
        child: MosaicPressFeedback(
          onPressed: () {},
          child: const MosaicSurface(
            padding: EdgeInsets.all(16),
            child: SizedBox(width: 120, height: 120),
          ),
        ),
      ),
    );
  }
}
```
