# mosaic_ui

Flutter component library for the Mosaic design system.

## Status

Foundations and primary primitives are in place. The package is usable
end-to-end via `examples/wallet_demo`.

## Roadmap

- [x] Tokens, mode, theme
- [x] `MosaicApp` canonical entry
- [x] Surface, press feedback, panel
- [x] State primitives (`DataState<T>`, `MosaicLiveSource<T>`)
- [x] Tile, live tile, grid
- [x] Motion primitives (state switcher, expand transition, pivot)
- [x] Surface expansion stack, command bar
- [x] Golden tests across mode × brightness
- [ ] List, input, notification card
- [ ] Component gallery

See [`docs/01-foundation/state-and-transitions.md`](../../docs/01-foundation/state-and-transitions.md)
for the architecture contract.

## Quick Look

```dart
import 'package:flutter/widgets.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

void main() {
  runApp(
    MosaicApp(
      title: 'Mosaic Demo',
      builder: (context) => const HomeSurface(),
    ),
  );
}
```

## Tests

```bash
flutter test                       # everything except goldens
flutter test --tags golden         # goldens only
flutter test --update-goldens --tags golden   # regenerate goldens
```

### Golden workflow

Goldens live in `test/goldens/<name>.<mode>.<brightness>.png`. Each
component runs against the four-cell matrix
(`metro/dark`, `metro/light`, `modern/dark`, `modern/light`) via
`runGoldenMatrix` in `test/goldens/_harness.dart`.

Goldens are platform-sensitive — fonts and anti-aliasing differ across
OSes — so they're committed from the host that generated them and CI
runs `flutter test --exclude-tags golden`. Regenerate after intentional
visual changes only, and on the same OS as the previous run.
