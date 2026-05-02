# Testing Strategy

Mosaic must be tested at design, component, and product levels.

## Test Types

```text
Unit tests
Widget tests
Golden tests
Interaction tests
Accessibility tests
Platform bridge tests
Manual device tests
```

## Component Acceptance Tests

Every component should define:

```text
Metro mode render
Modern mode render
Light/dark render eventually
Loading state
Empty state
Error state
Disabled state where applicable
Accessibility labels
```

## Tile Tests

```text
Small tile maps to 1x1 grid span
Medium tile maps to 2x2 grid span
Wide tile maps to 4x2 grid span
Tall tile maps to 2x4 grid span
Large tile maps to 4x4 grid span
Hero tile maps to 4x6 grid span
Metro mode elevation is zero
Live tile handles stream update
Live tile handles stream error
```

## Launcher Tests

```text
pin tile
unpin tile
move tile
resize tile
enter edit mode
exit edit mode
search apps
open app
```

## Manual Device Matrix

```text
Android phone
Android tablet
Linux touch laptop
Linux handheld/mini PC
iPhone for UI kit/widgets only
```
