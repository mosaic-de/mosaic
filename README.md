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

## The Ecosystem

Every app lives in its own repo under
[`mosaic-de`](https://github.com/mosaic-de) and is cloned into `apps/`
here, which is gitignored on purpose — this repo is the design system,
not a monorepo. Each app depends on `mosaic_ui` as a git dependency,
with a `dependency_overrides` pointing at the sibling checkout so
in-repo edits are picked up during development.

| Repo | Role |
|---|---|
| [`mosaic-launcher`](https://github.com/mosaic-de/mosaic-launcher) | Android launcher — three home layouts, live tiles, widgets |
| [`mosaic-comms`](https://github.com/mosaic-de/mosaic-comms) | Phone, contacts and SMS, multi-SIM |
| [`mosaic-clock`](https://github.com/mosaic-de/mosaic-clock) | Clock, alarms, stopwatch, world clock |
| [`mosaic-gallery`](https://github.com/mosaic-de/mosaic-gallery) | Photos and video, editing, encrypted vault |
| [`mosaic-file-manager`](https://github.com/mosaic-de/mosaic-file-manager) | Files — browse, search, storage |
| [`mosaic-music`](https://github.com/mosaic-de/mosaic-music) | Local music library and player |
| [`mosaic-player`](https://github.com/mosaic-de/mosaic-player) | Media player for arbitrary files and streams |
| [`mosaic-mail`](https://github.com/mosaic-de/mosaic-mail) | IMAP/SMTP mail client |
| [`mosaic-notes`](https://github.com/mosaic-de/mosaic-notes) | Notes, encrypted at rest |
| [`mosaic-todo`](https://github.com/mosaic-de/mosaic-todo) | Tasks with reminders and recurrence |
| [`mosaic-budget`](https://github.com/mosaic-de/mosaic-budget) | Expenses, budgets and accounts |
| [`mosaic-calculator`](https://github.com/mosaic-de/mosaic-calculator) | Calculator — scientific, tape, converters |
| [`mosaic-wallet-ui`](https://github.com/mosaic-de/mosaic-wallet-ui) | Wallet reference UI |
| [`mosaic-weather`](https://github.com/mosaic-de/mosaic-weather) | Weather reference app (real Open-Meteo data) |

### Conventions every app follows

These are not style preferences; each one exists because its absence
caused a real defect:

- **All visual values from tokens.** No hardcoded colour, radius,
  duration or spacing. `package:flutter/widgets.dart`, never
  `material.dart` beyond `show Icons`.
- **`MosaicApp` → `MosaicSurfaceHost` → surfaces.** Sub-surfaces are
  pushed on the surface stack, not through Navigator routes.
- **Correct in all three modes.** Metro, modern and aurora, each
  covered by a widget test.
- **Platform access behind an interface**, with an Android
  implementation and an in-memory one for tests — see
  `apps/mosaic_launcher/lib/src/app_source.dart`.
- **Secrets in `flutter_secure_storage`, data in `sqflite_sqlcipher`.**
  The database key is generated on first run and never stored in plain
  preferences. **A missing key over an existing database fails loudly**
  rather than silently recreating it empty.
- **An empty list must never be able to mean "no permission".**
  Denied, granted-but-empty and read-failed are three states with three
  messages. This shipped as a real bug once and reached a user.
- **`theme_choice.dart` is shared verbatim** across apps — system /
  dark / light, read before `runApp`, and a brightness change that
  merely follows the device is never persisted, or "system" silently
  becomes "dark" on the first nightfall.

### Toolchain

Every app pins the same three things, each of which cost hours when
missed. See `apps/mosaic_clock/android/` for the canonical versions.

```text
environment: sdk: ^3.12.0     below it the whole test suite fails to
                              load, while `flutter analyze` still passes
AGP 8.11.1 / Kotlin 2.2.20    `flutter create` emits AGP 9, which this
Gradle 8.14                   Flutter cannot configure
-Xmx3G  metaspace 1G          the template's 8G starves concurrent
                              sibling builds on a 16 GB host
```

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
