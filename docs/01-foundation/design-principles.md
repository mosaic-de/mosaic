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
Metro mode: strict, flat, sharp
Modern mode: softer, still structured
Custom mode: token-based extension
```
