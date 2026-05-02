# Roadmap

## Phase 0: Design Lock

Goal: define enough design to prevent random implementation.

Deliverables:

```text
product vision
design principles
tokens
tile system
component map
launcher spec
core app patterns
platform strategy
```

Exit criteria:

```text
Docs explain what to build.
Docs explain what not to build.
Tile system has states, sizes, and behavior.
```

## Phase 1: Flutter Foundation

Goal: build the first package skeleton.

Deliverables:

```text
mosaic_ui package
MosaicTokens
MosaicTheme
MosaicApp
MosaicSurface
MosaicText
MosaicGrid
```

Testable steps:

```bash
flutter create packages/mosaic_ui --template=package
cd packages/mosaic_ui
flutter analyze
flutter test
```

Acceptance criteria:

```text
Package imports cleanly.
Tokens are not hardcoded inside components.
Metro and Modern modes exist.
```

## Phase 2: Tile System

Deliverables:

```text
MosaicTile
MosaicLiveTile
MosaicTileSize
MosaicTileState
MosaicTileContent
MosaicGrid
```

Testable steps:

```text
Render every tile size.
Render every tile state.
Render Metro mode with zero elevation.
Render Modern mode with subtle radius/elevation.
```

Acceptance criteria:

```text
All semantic tile sizes work.
All tile states are visible.
Live tile updates from stream.
```

## Phase 3: Launcher MVP

Deliverables:

```text
mosaic_launcher app
home grid
pinned tiles
app list
search
edit mode
tile resize
```

Acceptance criteria:

```text
Pin app to home.
Move tile.
Resize tile.
Search app list.
Live tile updates without opening app.
```

## Phase 4: CLI MVP

Deliverables:

```text
mosaic_cli
mosaic create
mosaic add tile
mosaic add pivot
mosaic theme set
mosaic metronize dry-run
```

Acceptance criteria:

```text
CLI can scaffold an app.
CLI can add MosaicApp wrapper.
CLI can report what it would change before modifying files.
```

## Phase 5: Core Apps

Build reference Mosaic versions:

```text
Contacts
Messages
Dialer
Calendar
Files
Settings
Lock Screen Demo
```

Acceptance criteria:

```text
Each app uses Mosaic primitives.
Each app exposes state first.
Each app avoids deep navigation.
```

## Phase 6: Native Bridges

Deliverables:

```text
Android contacts bridge
Android installed apps bridge
Android notification bridge
iOS contacts/calendar bridge
Linux notifications/power/network bridge
```

## Phase 7: Ecosystem

Deliverables:

```text
docs website
component gallery
example apps
golden tests
accessibility audit
Figma or design source files
```
