# Navigation Model

Mosaic navigation is surface-first.

## Primary Primitives

```text
Vertical scroll = more content
Horizontal pivot = switch context
Tap = focus or expand
Long press = configure
Back = collapse before exit
Command bar = contextual action
```

## Avoid Deep Navigation

Bad:

```text
Wallet → Accounts → Transactions → Details → Filters → Export
```

Better:

```text
Wallet Surface
  Balance Tile
  Transactions Tile
  Insights Tile
  Command Bar
```

## Collapse Before Exit

Back navigation should first collapse expanded surfaces before exiting the app.
