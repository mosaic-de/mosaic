# Mosaic Design System

Mosaic is a data-first, touch-first design system inspired by the
clarity of Metro, built for Flutter — launchers, core apps, handhelds,
Linux shells, and future OS targets.

Mosaic is not a launcher skin. It is a design language for rebuilding
app journeys around **state, surfaces, tiles, command bars, pivots, and
shallow navigation**.

## What Lives Here

This repo holds the design system and its docs:

```text
docs/                    authoritative specs
packages/
  mosaic_ui/             Flutter component library
  mosaic_cli/            scaffolder + "metronizer" CLI (placeholder)
```

Reference implementations live in their own repos under
[`mosaic-de`](https://github.com/mosaic-de):

| Repo | Role |
|---|---|
| [`mosaic-wallet-ui`](https://github.com/mosaic-de/mosaic-wallet-ui) | Wallet reference UI |
| [`mosaic-weather`](https://github.com/mosaic-de/mosaic-weather) | Weather reference app (real Open-Meteo data) |

Ecosystem apps and the launcher are developed as separate, currently
private repos under the same org and will open up as they ship. Each
public app pulls `mosaic_ui` from this repo as a git dependency.

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

### Modes

Three visual modes ship in the box. A mode changes what a surface is
made of; it never changes what is on the surface or how it is laid out.

| Mode | Surface |
|---|---|
| `metro` | flat, sharp, opaque — the default |
| `modern` | softened radius, subtle elevation, still opaque |
| `aurora` | translucent panes, backdrop blur, hairline edges, real depth |

Structure — grid columns, spacing scale, semantic tile spans — is
identical in all three. That separation is what lets the launcher offer
layout and mode as two independent settings rather than a list of
bundled themes. See
[`docs/01-foundation/design-tokens.md`](docs/01-foundation/design-tokens.md).

## Quick Start for Contributors

Start with these documents in order:

1. [`docs/00-overview/product-vision.md`](docs/00-overview/product-vision.md)
2. [`docs/01-foundation/design-principles.md`](docs/01-foundation/design-principles.md)
3. [`docs/01-foundation/state-and-transitions.md`](docs/01-foundation/state-and-transitions.md)
4. [`docs/02-components/tile-system.md`](docs/02-components/tile-system.md)
5. [`docs/05-roadmap/roadmap.md`](docs/05-roadmap/roadmap.md)

Working in `packages/mosaic_ui`:

```bash
cd packages/mosaic_ui
flutter pub get
flutter analyze
flutter test --exclude-tags golden     # everything except snapshots
flutter test --tags golden             # snapshots only
flutter test --update-goldens --tags golden   # regenerate snapshots
```

CI runs `flutter analyze`, `flutter test --exclude-tags golden`, and
`dart format --set-exit-if-changed .` on every PR. Goldens are
host-specific and excluded from CI by design.

## Build Philosophy

Design first. Then components. Then launcher. Then core apps. Then
native bridges.
