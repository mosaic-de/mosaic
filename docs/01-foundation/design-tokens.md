# Design Tokens

Tokens are the foundation. Components must not hardcode visual values.

## Token Groups

```text
color
typography
spacing
radius
elevation
effect
motion
grid
```

### Structure vs. skin

The groups split into two kinds, and the split is load-bearing:

```text
structure   spacing, grid, tile spans      — identical in every mode
skin        color, radius, elevation,      — the mode's whole job
            effect, motion, typography
```

A mode may only change skin tokens. Changing a structure token from a
mode would mean switching mode reflows the screen, and the launcher's
"home layout" and "visual mode" could no longer be independent settings.

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

## Aurora Mode Defaults

Layered translucent panes. The only default mode whose surfaces are not
opaque, and therefore the only one that costs a `BackdropFilter` per
surface — `MosaicEffectTokens.isGlass` exists so components can skip
that work entirely in the other two modes.

```text
radius.tile: 20px
radius.panel: 28px
elevation.tile: 2      panel: 8      overlay: 16
effect.surfaceBlur: 32       overlayBlur: 52
effect.surfaceOpacity: 0.46 dark / 0.58 light
effect.strokeWidth: 1        strokeOpacity: 0.18 dark / 0.10 light
effect.saturation: 1.7
effect.sheenOpacity: 0.10 dark / 0.16 light
motion: longer, easeOutCubic
grid: still strict — margin and gutter widen, columns do not
```

### The four parts of glass

Blur and transparency alone produce fog, not glass. All four of these
are load-bearing, and dropping any one is the usual reason a hand-rolled
material looks muddy:

```text
heavy blur      32+, not 15 — a light blur reads as a smudge
low fill        the pane is mostly backdrop, not mostly tint
saturation      pushed back above 1.0, because blur averages colour out
lit top edge    so the pane has a surface instead of being a hole
```

Saturation is composed *inside* the blur — `ImageFilter.compose` applies
`inner` first, so the matrix runs on the raw backdrop and the blur on
its result. Saturating afterwards would amplify the averaged, muddy
colour rather than the original.

Three asymmetries are deliberate:

- **Dark glass takes a brighter hairline than light glass.** On a dark
  backdrop a faint edge disappears and the pane reads as a smudge.
- **Light glass takes a stronger sheen than dark** — the inverse, since
  a white highlight barely registers on a light surface and blows out on
  a dark one.
- **The gutter widens while the column count does not.** Translucent
  panes need air between them or their blurred edges bleed together, but
  changing columns would be structural, and modes do not get to do that.

## Hard Rule

Softer modes may soften Mosaic. They must never turn Mosaic into
Material UI, and they must never change structure.
