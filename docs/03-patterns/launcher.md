# Mosaic Launcher v0.1

The launcher is the first full reference app built from the Mosaic Tile System.

## Required Features

```text
Home/start surface
Pinned tiles
Semantic grid
Live tile updates
App list
Search
Edit/reorder mode
Tile resizing
Groups
Theme mode switch
```

## Grid

Default mobile grid:

```text
4 columns
8px base spacing
16px margin
semantic tile spans
```

## Home Surface

```text
Greeting / time
Live tiles
Pinned apps
System status tiles
Optional groups
```

## App List

Should feel like Metro:

```text
Large typography
Alphabetical grouping
Fast search
No icon-grid clutter by default
```

## Edit Mode

Long press activates edit mode.

Supported actions:

```text
move
resize
unpin
change tile mode
toggle live updates
```

## Acceptance Criteria

- User can pin, unpin, move, and resize a tile.
- Tile sizes remain semantic.
- Launcher never creates random masonry layout.
- Live tile can update without opening app.
- App list can search installed apps.
