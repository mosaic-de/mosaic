# Mosaic Design System

Mosaic is a data-first, touch-first design system inspired by the clarity of Metro, built for Flutter, launchers, core apps, handhelds, Linux shells, and future OS targets.

Mosaic is not just a launcher skin. It is a design system for rebuilding app journeys around state, surfaces, tiles, command bars, pivots, and shallow navigation.

## Repository Goals

1. Define the Mosaic design language.
2. Build a Flutter UI kit.
3. Build a CLI that can scaffold and metronize Flutter apps.
4. Build a Mosaic launcher as the reference implementation.
5. Build core app patterns: contacts, SMS, dialer, calendar, files, settings, lock screen surfaces.
6. Add native bridges for Android, iOS, Linux, and later experimental platforms like Fuchsia.

## Default Design Position

Mosaic defaults to Metro-like structure:

- Flat surfaces
- No artificial elevation
- No heavy shadows
- Strict semantic grid
- Large typography
- Live data tiles
- Shallow navigation
- Contextual command bars

Optional visual modes can soften radius and add subtle elevation, but must not break Mosaic structure.

## Quick Start for Contributors

Read these first:

1. [`docs/00-overview/product-vision.md`](docs/00-overview/product-vision.md)
2. [`docs/01-foundation/design-principles.md`](docs/01-foundation/design-principles.md)
3. [`docs/02-components/tile-system.md`](docs/02-components/tile-system.md)
4. [`docs/05-roadmap/roadmap.md`](docs/05-roadmap/roadmap.md)
5. [`CLAUDE.md`](CLAUDE.md)

## Monorepo Layout

```text
mosaic-design-system/
  docs/
  packages/
    mosaic_ui/
    mosaic_cli/
    mosaic_native_android/
    mosaic_native_ios/
    mosaic_native_linux/
  apps/
    mosaic_launcher/
    core/
  examples/
```

## Build Philosophy

Design first. Then components. Then launcher. Then core apps. Then native bridges.
