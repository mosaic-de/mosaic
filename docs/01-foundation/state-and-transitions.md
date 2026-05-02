# State and Transitions

Mosaic components must handle many concurrent concerns: a tile can be pressed, refreshing in the background, expanded into a panel, in dark Metro mode, and disabled — all at once. This document defines the architecture that keeps that tractable.

It is the contract for every stateful component in `packages/mosaic_ui`. If a component cannot be expressed in this model, update this doc before bending the model.

## 1. State as Orthogonal Layers

A single state enum covering every combination explodes combinatorially and resists extension. Mosaic models component state as **four independent layers** that compose:

| Layer | Type | Drives |
|---|---|---|
| `DataState<T>` | sealed: idle / loading / ready / empty / error | tile body content |
| `InteractionState` | enum: idle / pressed / focused / hovered / disabled | press feedback, opacity |
| `LayoutState` | enum: collapsed / expanding / expanded / collapsing | size, expand transition |
| `ThemeState` | from `MosaicTheme` inherited widget | mode + tokens |

A tile can be `{pressed, error, collapsed, Metro+dark}` without any single piece of code knowing about all four. Each layer renders independently and is golden-testable in isolation.

A fifth, scoped layer — `EditState` (browse / editing / reordering) — is provided by `MosaicEditScope` for launcher-style edit modes. It is not part of every component because it is a shell-level concern.

## 2. DataState\<T\>

The "live tile" requirements (last-known value, loading, stream update, error fallback, empty fallback, stale indicator) collapse into one sealed type:

```dart
sealed class DataState<T> {
  const DataState();
}

class DataIdle<T> extends DataState<T> {
  const DataIdle();
}

class DataLoading<T> extends DataState<T> {
  final T? lastKnown;
  final bool isInitial;
  const DataLoading({this.lastKnown, this.isInitial = false});
}

class DataReady<T> extends DataState<T> {
  final T value;
  final bool isStale;
  final bool isUpdating;
  const DataReady(this.value, {this.isStale = false, this.isUpdating = false});
}

class DataEmpty<T> extends DataState<T> {
  const DataEmpty();
}

class DataError<T> extends DataState<T> {
  final Object error;
  final T? lastKnown;
  const DataError(this.error, {this.lastKnown});
}
```

### Invariants

1. **`lastKnown` is preserved across non-initial transitions.** A `DataReady` followed by a refresh becomes `DataLoading(lastKnown: previousValue)` — the tile keeps showing the previous value with a loading overlay rather than flickering to a skeleton.
2. **`isInitial` distinguishes first-load from refresh.** First load may render a skeleton; subsequent loads render the previous value with an updating indicator.
3. **`isStale` and `isUpdating` are independent.** A value can be stale (older than the freshness window) without an in-flight refresh, and vice versa.
4. **Errors carry `lastKnown` too.** A failed refresh after success shows the previous value with an inline error chip, not a full error screen.

## 3. The Live Data Boundary

`packages/mosaic_ui` must not force consumers into a state-management library. The boundary is `MosaicLiveSource<T>`:

```dart
abstract class MosaicLiveSource<T> {
  Stream<DataState<T>> get states;
}
```

Built-in adapters convert common inputs into this shape:

```text
MosaicLiveSource.fromStream(Stream<T>)              wraps with loading/ready/error inference
MosaicLiveSource.fromFuture(Future<T> Function(),   for periodic polling
                            interval: Duration)
MosaicLiveSource.fromListenable(ValueListenable<T>) for Riverpod/Provider/etc.
MosaicLiveSource.static(T)                          for non-live content
```

Consumers who pass `Stream<T>` never need to construct `DataState` themselves. Consumers who already produce `DataState<T>` (e.g. via Riverpod `AsyncValue` mapped through a small extension) can implement the interface directly.

## 4. Tokens Drive Every Transition

No widget hardcodes a `Duration`, `Curve`, color, radius, or spacing value. `MosaicMotionTokens` exposes:

```dart
class MosaicMotionTokens {
  final Duration press;     // Metro 80ms, Modern 120ms
  final Duration update;    // 120-180ms
  final Duration expand;    // 180-240ms
  final Duration collapse;  // 160-220ms
  final Duration pivot;     // 180-260ms
  final Curve standardCurve;
  final double scale;       // test override; default 1.0, set 0 for instant
}
```

Three motion primitives consume these tokens; every state-driven animation in the system goes through one of them:

- **`MosaicStateSwitcher`** — crossfades between `DataState` renderings using `motion.update`. Wraps `AnimatedSwitcher`.
- **`MosaicExpandTransition`** — shared-element expand/collapse driven by `LayoutState`, using `motion.expand` / `motion.collapse`.
- **`MosaicPressFeedback`** — `InteractionState` → visual feedback. Metro: background dim only. Modern: 0.98 scale + dim.

## 5. Mode Switching

`MosaicMode.metro` and `MosaicMode.modern` are complete token sets exposed via the `MosaicTheme` inherited widget. A mode switch is a token swap; descendants rebuild via `InheritedWidget` notification.

**Default behavior is instant.** Metro should feel snappy and a crossfade undermines that. Opt-in animated switching is available via `MosaicTheme.crossfade(duration: tokens.motion.update)` for demos and gallery views.

Debug-mode lint: `MosaicLint` asserts no descendant pulls `Theme.of(context)` color/radius/spacing values, forcing tokens.

## 6. Tile Rendering Pipeline

A `MosaicTile` composes top-down:

```text
MosaicSurface             tokens → background, radius, brightness
 └─ MosaicPressFeedback   InteractionState → dim/scale
     └─ MosaicTileFrame   semantic size → grid span, padding
         └─ MosaicStateSwitcher    DataState → swap body
             ├─ tileBuilder(value)        when ready
             ├─ MosaicLoadingBody         when loading and no lastKnown
             ├─ MosaicEmptyBody           when empty
             ├─ MosaicErrorBody           when error and no lastKnown
             └─ overlays                  stale dot, updating shimmer, error chip
```

The `tileBuilder` is the only piece consumers write. Everything around it is owned by Mosaic and golden-tested.

## 7. Surfaces Own Their Expansion Stack

A `MosaicSurface` keeps an internal stack of expanded children. Expanding a tile pushes onto this stack rather than calling `Navigator.push`. Back navigation is wired via `PopScope`:

```text
back pressed
  ├─ surface stack non-empty → pop surface stack (collapse animation)
  └─ surface stack empty     → propagate to enclosing route
```

This is what makes "shallow journeys" implementable. Most of what looks like navigation never touches `Navigator`. New routes are reserved for genuine context shifts (different app, different identity).

Pivots use a `MosaicPivotController` — analogous to `TabController` — with horizontal swipe and `motion.pivot` driven transitions.

## 8. Testability Contract

Every stateful Mosaic component must expose a debug factory:

```dart
class MosaicComponentDebug {
  static List<Widget> states(Widget Function(DataState<dynamic>) builder);
  // returns one widget per canonical state: idle, loading-initial,
  // loading-with-lastKnown, ready, ready-stale, ready-updating,
  // empty, error, error-with-lastKnown
}
```

This feeds golden test generation directly. `MosaicTheme.test(mode, brightness, motionScale: 0)` flattens animation duration to zero so widget tests do not flake on timing.

## 9. Build Order

| Phase | Ships | Unblocks |
|---|---|---|
| A | Tokens + Theme + Mode + test helpers | everything else |
| B | `MosaicSurface` + `MosaicPressFeedback` | InteractionState golden tests |
| C | `DataState<T>` + `MosaicLiveSource<T>` adapters | unit-testable, no widgets required |
| D | `MosaicTile` + `MosaicLiveTile<T>` + `MosaicGrid` | wallet_demo renders |
| E | Motion primitives (`StateSwitcher`, `ExpandTransition`, `Pivot`) | wallet_demo feels alive |
| F | Surface expansion stack + `MosaicCommandBar` + `PopScope` | launcher MVP can start |

Each phase ships something independently testable. Phase D is the first user-visible milestone.

## 10. Refusal Conditions

The architecture forbids:

- A tile widget reading `Theme.of(context)` for any visual value. Use tokens.
- A widget hardcoding a `Duration` or `Curve`. Use motion tokens.
- A single state enum that conflates data, interaction, and layout concerns.
- A `Navigator.push` used to expand a tile or surface child. Use the surface expansion stack.
- A live tile that flickers to empty/skeleton during a refresh. Preserve `lastKnown`.
- A motion transition that runs even when the user has reduced-motion enabled. Respect `MediaQuery.disableAnimations` by clamping `motion.scale` to 0.

## Open Questions

These are deferred until first usage forces a decision:

- Should `DataState<T>` be sealed in the public API, or sealed-internal with a public adapter? Sealed-public is more honest but locks the shape.
- Should `MosaicLiveSource` expose backpressure / pause semantics for off-screen tiles, or is that the consumer's job?
- Should reduced-motion produce instant transitions or just shorter ones? Spec says instant; revisit if testers report jarring snap.
