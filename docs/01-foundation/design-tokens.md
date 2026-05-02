# Design Tokens

Tokens are the foundation. Components must not hardcode visual values.

## Token Groups

```text
color
typography
spacing
radius
motion
grid
state
surface
```

## Example Token Shape

```json
{
  "mode": "metro",
  "color.background": "#0B0B0C",
  "color.surface": "#121214",
  "color.surface.active": "#1A1A1F",
  "color.text.primary": "#FFFFFF",
  "color.text.secondary": "#A1A1AA",
  "spacing.unit": 8,
  "radius.tile": 2,
  "radius.panel": 0,
  "elevation.tile": 0,
  "motion.fast": 120,
  "motion.normal": 220,
  "grid.columns.mobile": 4
}
```

## Metro Mode Defaults

```text
radius.tile: 0–6px
elevation.tile: 0
shadow: none
spacing.unit: 8px
grid: strict
```

## Modern Mode Defaults

```text
radius.tile: 10–16px
elevation.tile: subtle only
shadow: soft and minimal
grid: still strict
```

## Hard Rule

Modern mode may soften Mosaic. It must never turn Mosaic into Material UI.
