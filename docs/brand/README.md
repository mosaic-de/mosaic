# Brand

## Marks

Every Mosaic app shares the same visual structure — a tessellation of
unequal tiles, hinting at the semantic-tile vocabulary (Hero, Wide,
Medium, Small) that the design system is built on. Apps are
distinguished by the accent color rather than by structure.

| File | Accent | Use |
|---|---|---|
| `mosaic_mark.svg` | `#00B7C3` cyan | Design system itself |
| `wallet_mark.svg` | `#F59E0B` amber | Wallet UI |
| `weather_mark.svg` | `#3B82F6` blue | Weather |
| `clock_mark.svg` | `#EF4444` red | Clock |
| `file_manager_mark.svg` | `#10B981` green | File manager |
| `launcher_mark.svg` | full palette | Launcher (surfaces every app) |

The marks live in `docs/brand/` because they describe identity, not
implementation. A monochrome alpha-tinted mark scales to a 24px favicon
and to a 1024px launcher icon equally well.

## Per-app accent → token mapping

The brand color is the consumer's `tokens.color.accent`. To brand an
app:

```dart
runApp(
  MosaicApp(
    title: 'Mosaic Wallet',
    initialMode: MosaicMode.metro,
    builder: (context) => WalletHome(),
  ),
);
```

Override the accent (and its derivatives) in a custom `MosaicTokens`
when the brand color isn't cyan. Future work: a `MosaicTokens.branded`
constructor that takes a base accent and derives the rest.

## Generating Android launcher icons

The mark SVGs are 96x96 viewbox. To bake them as Android launcher
icons:

1. Render the SVG at 1024x1024 to a PNG (any SVG-to-PNG tool: ImageMagick,
   Inkscape CLI, online converter).
2. Drop the PNG at `<app>/assets/launcher_icon.png`.
3. Add `flutter_launcher_icons` as a dev dependency and configure it in
   pubspec:
   ```yaml
   dev_dependencies:
     flutter_launcher_icons: ^0.13.0

   flutter_launcher_icons:
     android: true
     ios: false
     image_path: assets/launcher_icon.png
   ```
4. Run `dart run flutter_launcher_icons`.

This is intentionally manual right now — it depends on an SVG renderer
that's outside the Dart toolchain.
