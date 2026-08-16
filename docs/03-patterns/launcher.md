# Mosaic Launcher

The launcher is the first full reference app built from the Mosaic
design system.

## Two independent axes

The launcher's appearance is **two settings, not one theme list**:

```text
home layout   grid | strata | ink      structure — what is on screen
visual mode   metro | modern | aurora  skin — what it is made of
```

They compose. Every layout renders correctly in every mode, because
`MosaicTokens` keeps structure (grid, spacing, tile spans) out of the
mode entirely. Bundling them into presets would delete real
combinations for no benefit.

Defaults: **grid + metro**. Both persist across cold starts;
`main()` reads the mode before `runApp` so the first frame is already
correct rather than flashing metro and snapping.

## Home layouts

### grid

Semantic Metro tiles packed to fill the viewport exactly.

```text
Non-scrolling            the viewport is the constraint, not the content
Fills all four edges     no ragged bottom, no dead strip
Demotes before dropping  an oversized tile shrinks rather than vanishing
Fills holes from usage   leftover cells get most-used apps
No folders               a folder on home is a worse drawer
```

`MosaicGridFit.resolve` derives columns from a ~78dp target cell, then
picks the row count that keeps cells nearest square, then stretches
both dimensions so the grid lands flush. `packToFit` places tiles
row-major first-fit against that fixed canvas.

Three rules earned by removing what did not work:

- **Home does not scroll.** A start screen that scrolls is a list
  wearing a grid costume. Capacity is `cols × rows`, and that is the
  tile budget.
- **No groups.** Category folders demoted a one-tap launch to a two-tap
  dig through a container with worse search than the drawer that
  already existed.
- **Fillers are suggestions, not state.** Cells the pinned list does not
  cover are filled from most-used apps, recomputed every build and never
  persisted. Long-press promotes one to a real pinned tile — which is
  how a user keeps the ones they want.
- **The stagger has to be seeded.** A hole is one cell by definition, so
  hole-filling can only ever produce 1×1s. Seed a uniform spine and the
  grid packs into a plain matrix with a straight edge down the side, and
  no amount of filling afterwards recovers the rhythm. The seed lays
  ranked apps against a repeating size pattern of **seven** entries —
  seven because a period that divides the column count lines the anchors
  up into columns and produces stripes on exactly the 4-, 5- and 6-wide
  grids that phones use.

Overflow is not an error: tiles that cannot be placed at any size stay
in the drawer.

### strata

Vertical stack of labelled context rails — `now`, then one rail per app
category, ranked by usage. Live data leads; app cards follow.

Inherits both grid rules: nothing scrolls, including the rails. A rail
shows as many cards as fit and no more. A horizontally scrolling row is
a folder that forgot to close.

### ink

Editorial index. A pinned glance block over a typographic list of apps:
pinned first, then everything else alphabetically, with live state as
inline metadata on the right rail. No tiles, no icons, no surfaces; a
hairline rule carries the hierarchy that a tile grid gets from colour.

The glance reads, in order: **next calendar events**, **next alarm**,
**unread count**, **battery**. Upcoming events lead because they are the
only line about the future and the most likely to change what someone
does in the next minute. Battery only takes the accent colour below 15%
and off charge — a row that is always coloured has stopped being a
signal.

Calendar comes from `CalendarContract.Instances`, not `Events`: `Events`
stores a recurrence rule rather than occurrences, so a weekly standup
would surface once at its original date and never again. The alarm is
`AlarmManager.getNextAlarmClock()`, which needs no permission and
reports the system-wide next alarm — so it works whether it was set in
Mosaic Clock or the OEM one.

The one layout that scrolls, and only below the glance block. An index
of 200 apps cannot be capped at a viewport and remain an index, but the
part you *look* at still never moves — only the part you search through
does.

Only real data appears in the glance, and each source states its own
absence: "clear" when the calendar is readable and empty, "tap to
allow" when the permission is missing, and no alarm row at all when
nothing is scheduled. Those are three different facts and they must not
render as the same blank.

## Widgets

Built-in live tiles (clock, weather, photos, news) are placeable from a
catalogue in edit mode, each with a set of sizes it renders well at.
One instance per kind — `PinnedTile.id` is `builtin:<kind>`, and that id
is what reorder and removal address.

Widgets insert at the front of the tile list: a widget is glanceable
state, and the top of the grid is where a glance lands.

Not yet built: hosting third-party Android `AppWidget`s via
`AppWidgetHost`. The catalogue is shaped so that becomes one more
provider rather than a rewrite.

## Edit mode

Long-press a tile.

```text
move      drag to reorder
resize    semantic sizes only
unpin
swap      repoint a slot at a different app
add       place a widget from the catalogue
```

## Acceptance criteria

- Home never scrolls in `grid` or `strata`; in `ink` the glance block is
  pinned and only the index scrolls.
- The grid reaches all four edges of the viewport.
- Tile sizes stay semantic; the launcher never produces masonry.
- A pinned app never silently disappears — it demotes, or it falls back
  to the drawer.
- Layout and mode are independently selectable and both persist.
- Live tiles update without opening an app.
- The drawer can search every installed app.
