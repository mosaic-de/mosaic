# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Mission

Build Mosaic: a Flutter-first, data-first design system and app ecosystem inspired by Metro, but evolved for modern cross-platform software.

Mosaic is not a Material theme, not a simple launcher, and not a random staggered grid. It is a structured interface model based on surfaces, tiles, live state, shallow navigation, and contextual actions.

## Repository Status (read this first)

This repo is currently in **Phase 0 (Design Lock)**. The code directories are scaffolding only:

- `packages/mosaic_ui/`, `packages/mosaic_cli/`, `apps/mosaic_launcher/`, `examples/wallet_demo/` each contain a single `README.md` and **no Flutter source, no `pubspec.yaml`, no tests**.
- There is no workspace tool (no melos, no pub workspace) and no Dart/Flutter toolchain config in the repo.
- CI (`.github/workflows/ci.yml`) only verifies that key markdown files exist. It does not run `flutter analyze` or `flutter test`.

Implication: the `flutter test / analyze / format` commands listed below are aspirational for once the package exists. The first real implementation work (per `TODO.md` and `docs/05-roadmap/roadmap.md`) is to scaffold `packages/mosaic_ui` with `flutter create --template=package` and start the Tile System.

## Monorepo Layout

```text
mosaic-design-system/
  docs/                          authoritative specs (see "Spec Authority" below)
  packages/
    mosaic_ui/                   primary Flutter UI library
    mosaic_cli/                  scaffolder + "metronizer" CLI
  apps/
    mosaic_launcher/             reference launcher built on the tile system
  examples/
    wallet_demo/                 reference surface pattern (Phase-0 target)
```

The README hints at future packages (`mosaic_native_android/ios/linux`, `apps/core/`); these do not exist on disk yet — do not assume their structure, design from the docs when you create them.

## Spec Authority

`docs/` is the source of truth for behavior. Treat it as you would a design contract — components and apps must conform to it, and undefined behavior must be specified there before being built.

```text
docs/00-overview/      product-vision.md
docs/01-foundation/    design-principles.md, design-tokens.md, navigation-model.md, state-and-transitions.md
docs/02-components/    tile-system.md, component-map.md, lock-screen-components.md
docs/03-patterns/      launcher.md, core-apps.md
docs/04-platforms/     platform-strategy.md
docs/05-roadmap/       roadmap.md
docs/06-testing/       testing-strategy.md
```

Before implementing a feature: read the matching doc. If behavior is undefined, update the doc first, then implement.

## Architecture: Modes, Surfaces, Tokens, Tiles

Four ideas tie the design system together. They are spread across multiple docs but they are the system:

1. **Modes.** Mosaic ships two design modes: `Metro` (flat, sharp, no elevation) and `Modern` (softer radius, subtle elevation, still strict grid). A future `Custom` mode extends via tokens. Every component must render correctly in both. Mode is a token-set switch, not per-widget styling.
2. **Surfaces over pages.** Apps are surfaces that expose state and actions, not page stacks. `Surface → expand → act → collapse` replaces `Home → Page → Page → Details`. Back collapses before exiting.
3. **Tokens, never hardcoded values.** Colors, radii, spacing, motion durations, typography, and grid columns all come from `MosaicTokens`. Hardcoding any of these is a bug. See `docs/01-foundation/design-tokens.md`.
4. **Semantic tile sizes (not masonry).** Tiles use a fixed vocabulary mapped to grid spans:

```text
Small  1x1   icon/status only
Medium 2x2   app/action/state preview
Wide   4x2   text-heavy live state
Tall   2x4   timeline/feed/vertical content
Large  4x4   dashboard summary
Hero   4x6   primary screen focus
```

A staggered-grid library is fine as an implementation detail. Random masonry output is not.

## Non-Negotiable Design Rules

1. Default mode is Metro-like.
2. Do not use Material-style raised buttons by default.
3. Do not use shadows or artificial elevation in Metro mode.
4. Do not create random masonry layouts. Use semantic tile sizes.
5. Use surfaces, tiles, pivots, panels, and command bars as the primary primitives.
6. Separate stateless components from stateful/live components.
7. Prefer shallow journeys over deep page stacks.
8. Do not recreate Android or iOS UI patterns unless explicitly required by platform constraints.
9. Core apps must feel native to Mosaic, not like skinned Android apps.
10. All optional softness must be controlled by design modes and tokens, not random per-widget styling.

## Coding Rules

- Prefer explicit types.
- Keep widgets small and composable.
- Do not hardcode colors, radius, spacing, durations, or typography. Use tokens.
- Every component must support:
  - Metro mode
  - Modern mode where applicable
  - Light and dark themes eventually
  - Accessibility labels
  - Golden tests later
- Every stateful component must document and render:
  - idle, loading, empty, error, updating/live, disabled (where applicable)
- Live tiles must support: last-known value, loading, stream update, error fallback, empty fallback, stale indicator (`docs/02-components/tile-system.md`).

## Flutter Package Targets

Primary package: `packages/mosaic_ui`

Initial public API to expose as the package fills in:

```dart
MosaicApp
MosaicTheme
MosaicTokens
MosaicSurface
MosaicTile
MosaicLiveTile
MosaicGrid
MosaicPivot
MosaicCommandBar
MosaicPanel
MosaicList
MosaicInput
MosaicNotificationCard
```

Full taxonomy of planned components is in `docs/02-components/component-map.md` — consult it before inventing a new component name; many already have a designated spelling.

## AI Agent Workflow

When asked to implement a feature:

1. Read the relevant doc(s) under `docs/`.
2. Update the spec first if behavior is undefined.
3. Implement the smallest useful slice.
4. Add tests or a test plan (see `docs/06-testing/testing-strategy.md` for required matrix).
5. Add an example screen where possible.
6. Avoid broad rewrites unless requested.

## First Implementation Milestone

Build the **Tile System** first. Required directory layout once `packages/mosaic_ui` is scaffolded:

```text
packages/mosaic_ui/lib/src/tokens/
packages/mosaic_ui/lib/src/theme/
packages/mosaic_ui/lib/src/tile/
packages/mosaic_ui/lib/src/grid/
examples/wallet_demo/
```

First components: `MosaicTheme`, `MosaicTokens`, `MosaicTile`, `MosaicLiveTile`, `MosaicGrid`, `MosaicCommandBar`.

Bootstrap command (per `docs/05-roadmap/roadmap.md`):

```bash
flutter create packages/mosaic_ui --template=package
```

## Commands

Once Flutter packages exist, prefer:

```bash
flutter analyze
flutter test
dart format .
```

Run from inside the relevant package directory (no workspace tool is configured yet, so commands do not fan out across packages).

CI currently only runs a structural file-existence check; it does not block on analyze/test. Treat local `flutter analyze` and `flutter test` as the real gate.

## Refusal Conditions for AI Agent

Do not implement:
- Material `Card` wrappers presented as Mosaic tiles.
- `FloatingActionButton` as a primary Mosaic pattern.
- Arbitrary tile sizes that bypass semantic sizing.
- Heavy shadows in Metro mode.
- Navigation flows that create deep page stacks without a spec justification.
