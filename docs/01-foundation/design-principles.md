# Design Principles

## 1. Information First

A screen should immediately answer what the user can know without opening another page.

## 2. Surfaces Over Pages

Mosaic treats screens as surfaces that expose state and action, not as page stacks.

## 3. Structure Over Decoration

Hierarchy is created using layout, contrast, typography, and motion. Not heavy shadows.

## 4. Flat by Default

Metro mode is flat by default:

```text
No artificial elevation.
No heavy shadows.
No raised buttons.
No floating UI unless explicitly justified.
```

## 5. Stateful and Stateless Thinking

Every screen separates:

```text
What is fixed?
What is changing?
What needs action?
```

## 6. Semantic Tiles, Not Random Masonry

Tiles use fixed semantic sizes and purposes. Flutter staggered grid can be an implementation detail, but Mosaic must not become random masonry UI.

## 7. Shallow Journeys

Prefer:

```text
Surface → expand → act → collapse
```

over:

```text
Home → Page → Page → Page → Details → Form
```

## 8. Modes, Not Random Overrides

Mosaic supports controlled design modes:

```text
Metro mode:  strict, flat, sharp, opaque
Modern mode: softer radius, subtle elevation, still opaque
Aurora mode: translucent panes, backdrop blur, real depth
Custom mode: token-based extension
```

## 9. Structure Is Not a Mode

A mode changes what a surface is *made of* — colour, radius, elevation,
blur, motion. It never changes what is *on* the surface or how that is
organised. Grid columns, spacing scale, and semantic tile spans are
identical across every mode.

This is why the launcher can offer "home layout" and "visual mode" as
two independent settings that compose, instead of a list of bundled
themes. The moment a mode is allowed to reflow a layout, that
independence is gone and every new mode multiplies the work.
