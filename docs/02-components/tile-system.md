# Mosaic Tile System v0.1

The tile system is the primitive. The launcher is the first full reference implementation.

## Tile Philosophy

Tiles are not cards. Tiles are information surfaces.

A tile may be:

```text
Static
Live
Interactive
Expandable
Actionable
```

## Semantic Tile Sizes

Use semantic sizes, not arbitrary masonry.

```text
Small     1 x 1
Medium    2 x 2
Wide      4 x 2
Tall      2 x 4
Large     4 x 4
Hero      4 x 6
```

## Tile Purpose

```text
Small  = icon/status only
Medium = app/action/state preview
Wide   = text-heavy live state
Tall   = timeline/feed/vertical content
Large  = dashboard summary
Hero   = primary screen focus
```

## Tile Anatomy

```text
Tile
  ├─ background surface
  ├─ icon/media area
  ├─ primary text
  ├─ secondary text
  ├─ metric/state value
  ├─ status indicator
  └─ optional action zone
```

## Tile States

Every tile must define:

```text
idle
pressed
focused
loading
empty
error
updating
expanded
disabled
```

## Behavior

### Tap

Default action. Usually opens, focuses, or expands the tile.

### Long Press

Enters configure/edit mode.

### Expand

A tile can expand into a panel without feeling like a full page jump.

### Update

Live changes should animate with small directional motion or crossfade. No playful bounce by default.

## Motion

```text
press: 80–120ms
update: 120–180ms
expand: 180–240ms
collapse: 160–220ms
pivot: 180–260ms
```

## Data Binding Model

A live tile should support:

```text
last known value
loading value
stream update
error fallback
empty fallback
stale indicator
```

The full state model, transition contract, and `DataState<T>` / `MosaicLiveSource<T>` types are defined in [`docs/01-foundation/state-and-transitions.md`](../01-foundation/state-and-transitions.md). That document is the source of truth — this section is a summary.

## Flutter API Sketch

```dart
MosaicTile(
  size: MosaicTileSize.wide,
  title: 'Wallet',
  subtitle: 'KES 24,500',
  status: MosaicTileStatus.idle,
  onTap: () {},
)

MosaicLiveTile<WalletSummary>(
  size: MosaicTileSize.large,
  stream: walletSummaryStream,
  builder: (context, summary) {
    return MosaicTileContent(
      title: 'Wallet',
      primaryValue: summary.balanceLabel,
      subtitle: summary.lastTransactionLabel,
    );
  },
)
```

## Testable Acceptance Criteria

- Metro mode tile renders with zero elevation.
- Metro mode tile uses token radius, not hardcoded radius.
- Tile sizes map to grid spans.
- Loading, empty, error, and updating states are visible.
- Live tile can render from a stream.
- Long press can trigger edit mode in launcher context.
