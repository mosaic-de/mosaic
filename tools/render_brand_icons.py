"""Render Mosaic brand marks to Android launcher icons.

We reproduce the geometry directly with Pillow rather than depending on
an SVG rasteriser — cairosvg needs cairo, which is not on this Windows
host. The SVGs in docs/brand/ are the human-readable source of truth and
must be kept in sync with the tables below by hand.

## Why marks differ per app

Every app used to share one abstract tessellation, recoloured. At 48 px
on a home screen that made Clock and Files distinguishable only by hue,
which defeats the point of an icon. Each app now gets geometry that says
what it *is*, drawn in the shared language: axis-aligned rectangles,
flat fills, no gradients, no diagonals. A mark is `base` rects in the
app's accent (varying alpha for depth) plus `ink` rects in white on top.

The launcher keeps the tessellation, since "many coloured tiles" is
literally what it is, and gets every ecosystem accent instead of one.

## Adaptive icons

Android 8+ masks legacy icons into a small badge on a white plate, which
looks broken next to modern apps. So we also emit an adaptive icon:

    mipmap-anydpi-v26/ic_launcher.xml   layer declaration
    mipmap-<dpi>/ic_launcher_foreground.png
    values/ic_launcher_background.xml   solid background colour

Adaptive foregrounds are drawn on a 108-unit canvas of which only the
centre 66 is guaranteed visible — launchers mask to circles, squircles
and rounded squares, and some parallax on scroll. The 96-unit mark is
scaled to 72 and centred, putting its 84-unit artwork inside 63 units,
comfortably within that safe zone.

Usage:
    python tools/render_brand_icons.py
"""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw

# ── Mark geometry, on a 96x96 grid ────────────────────────────────────
# base: (x, y, w, h, alpha) filled with the app accent.
# ink:  (x, y, w, h, alpha) filled with white, painted over the base.

# Generic Mosaic tessellation. Used by the design system itself and by
# apps whose identity is "a Mosaic app" rather than a specific object.
MOSAIC_BASE = [
    (6, 6, 40, 40, 1.00),
    (50, 6, 40, 22, 0.70),
    (50, 32, 18, 14, 0.45),
    (72, 32, 18, 14, 0.85),
    (6, 50, 22, 40, 0.55),
    (32, 50, 58, 18, 0.90),
    (32, 72, 26, 18, 0.35),
    (62, 72, 28, 18, 0.65),
]

# Clock: a four-quadrant field with hands knocked out in white. The
# hands read 3:00 rather than the conventional 10:10 because 10:10 needs
# diagonals, and diagonals are not in this language. Orthogonal hands
# also survive the 48 px mdpi render without anti-aliasing mush.
# The quadrants are deliberately gapless. An earlier version spaced them
# like the tessellation, and the resulting white gutters ran corner to
# corner straight through the middle — competing with the hands so the
# whole thing read as a four-pane window. On a clock the hands must be
# the only white on the face.
CLOCK_BASE = [
    (6, 6, 42, 42, 1.00),
    (48, 6, 42, 42, 0.72),
    (6, 48, 42, 42, 0.58),
    (48, 48, 42, 42, 0.88),
]
CLOCK_INK = [
    (42, 22, 12, 28, 1.00),  # hour hand, pointing up
    (48, 42, 32, 12, 1.00),  # minute hand, pointing right, longer
    # Hub sized close to the hand width. Wider than that and the joint
    # swells into a blob that reads as a hammer head rather than a pivot.
    (40, 40, 16, 16, 1.00),
]

# Files: folder tab plus body, with two sheets of unequal height inside.
# The uneven sheets are what stop it reading as a plain rounded square.
FILES_BASE = [
    (6, 16, 36, 12, 0.72),  # tab
    (6, 28, 84, 62, 1.00),  # body
]
FILES_INK = [
    (18, 42, 30, 36, 0.92),
    (52, 42, 26, 28, 0.55),
]

# Notes: a page with written lines. The lines are unequal on purpose —
# a stack of equal bars reads as a list or a menu, while a short last
# line reads as prose that stopped mid-sentence.
NOTES_BASE = [(12, 6, 72, 84, 1.00)]
NOTES_INK = [
    (26, 22, 30, 10, 1.00),  # heading, shorter and heavier
    (26, 42, 44, 8, 0.80),
    (26, 56, 44, 8, 0.80),
    (26, 70, 26, 8, 0.60),  # trailing part-line
]

# Calculator: display strip over a keypad. Six keys, not nine — at
# 48 px mdpi a 3x3 grid of keys closes up into a texture, and the point
# is that it reads as *keys* rather than as a grid.
CALC_BASE = [(6, 6, 84, 84, 1.00)]
CALC_INK = [
    (18, 18, 60, 16, 1.00),  # display
    (18, 44, 16, 14, 0.90),
    (40, 44, 16, 14, 0.90),
    (62, 44, 16, 14, 0.90),
    (18, 64, 16, 14, 0.70),
    (40, 64, 16, 14, 0.70),
    (62, 64, 16, 14, 0.70),
]

# Comms: a speech bubble with a squared-off tail. The tail is what
# stops it reading as a plain panel, and it has to be a rectangle —
# the usual triangular tail is a diagonal, which this language does not
# have. Three dots rather than message lines, so it is not confused
# with the Notes page.
COMMS_BASE = [
    (8, 14, 80, 54, 1.00),  # bubble
    (20, 68, 18, 14, 1.00),  # tail
]
COMMS_INK = [
    (19, 34, 14, 14, 1.00),
    (41, 34, 14, 14, 0.85),
    (63, 34, 14, 14, 0.70),
]

# Gallery: two stacked photos, the rear one dimmed and offset so the
# stack reads as more than one image, with a sun over a horizon inside
# the front one.
#
# The horizon runs flush to the front photo's left, right and bottom
# edges. An earlier version inset it, and a floating bar under a small
# square stops being a landscape and starts being a form field with a
# label. Meeting the edges is what makes it ground.
GALLERY_BASE = [
    (30, 6, 60, 48, 0.55),  # photo behind
    (6, 26, 68, 64, 1.00),  # photo in front
]
GALLERY_INK = [
    (16, 36, 16, 16, 1.00),  # sun
    (6, 70, 68, 20, 0.88),  # horizon, flush to three edges
]

MARKS: dict[str, tuple[list, list]] = {
    "mosaic": (MOSAIC_BASE, []),
    "clock": (CLOCK_BASE, CLOCK_INK),
    "files": (FILES_BASE, FILES_INK),
    "notes": (NOTES_BASE, NOTES_INK),
    "calculator": (CALC_BASE, CALC_INK),
    "comms": (COMMS_BASE, COMMS_INK),
    "gallery": (GALLERY_BASE, GALLERY_INK),
}

# Launcher rainbow: same tessellation, but each rect carries its own
# ecosystem accent at full opacity.
RECTS_RAINBOW = [
    (6, 6, 40, 40, (0x00, 0xB7, 0xC3)),  # mosaic cyan
    (50, 6, 40, 22, (0xF5, 0x9E, 0x0B)),  # wallet amber
    (50, 32, 18, 14, (0x3B, 0x82, 0xF6)),  # weather blue
    (72, 32, 18, 14, (0x10, 0xB9, 0x81)),  # file_manager green
    (6, 50, 22, 40, (0xEF, 0x44, 0x44)),  # clock red
    (32, 50, 58, 18, (0xA8, 0x55, 0xF7)),  # purple
    (32, 72, 26, 18, (0xEC, 0x48, 0x99)),  # pink
    (62, 72, 28, 18, (0xF5, 0x9E, 0x0B)),  # wallet amber (echo)
]

WHITE = (0xFF, 0xFF, 0xFF)

# Adaptive-icon plate. Mosaic's metro dark background, so the accent
# marks read the same way they do on the launcher's own dark surface.
BACKGROUND_HEX = "#0B0B0C"

# (path, mark name, accent rgb). "rainbow" is special-cased.
#
# Every app gets its own hue as well as its own geometry. Colour alone
# was the original mistake — with one shared mark, apps were told apart
# only by hue, which is exactly what fails at 48 px on a crowded home
# screen and fails completely for anyone who cannot distinguish them.
APP_DIRS: list[tuple[str, str, tuple[int, int, int] | None]] = [
    ("examples/wallet_demo", "mosaic", (0xF5, 0x9E, 0x0B)),
    ("examples/weather_demo", "mosaic", (0x3B, 0x82, 0xF6)),
    ("apps/mosaic_launcher", "rainbow", None),
    ("apps/mosaic_clock", "clock", (0xEF, 0x44, 0x44)),  # red
    ("apps/mosaic_file_manager", "files", (0x10, 0xB9, 0x81)),  # green
    ("apps/mosaic_notes", "notes", (0xEA, 0xB3, 0x08)),  # yellow
    ("apps/mosaic_calculator", "calculator", (0x8B, 0x5C, 0xF6)),  # violet
    ("apps/mosaic_comms", "comms", (0x63, 0x66, 0xF1)),  # indigo
    ("apps/mosaic_gallery", "gallery", (0xEC, 0x48, 0x99)),  # pink
]

DPIS = {
    "mdpi": 48,
    "hdpi": 72,
    "xhdpi": 96,
    "xxhdpi": 144,
    "xxxhdpi": 192,
}

# Adaptive foregrounds are authored at 108 units; Android expects the
# same per-dpi ladder scaled from that baseline rather than from 48.
ADAPTIVE_DPIS = {
    "mdpi": 108,
    "hdpi": 162,
    "xhdpi": 216,
    "xxhdpi": 324,
    "xxxhdpi": 432,
}

REPO_ROOT = Path(__file__).resolve().parent.parent

ADAPTIVE_XML = """<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>
"""

BACKGROUND_XML = f"""<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">{BACKGROUND_HEX}</color>
</resources>
"""


def _draw(
    draw: ImageDraw.ImageDraw,
    rects: list,
    rgb: tuple[int, int, int] | None,
    scale: float,
    offset: float = 0.0,
) -> None:
    """Paint `rects` scaled onto the canvas.

    When `rgb` is None each rect is expected to carry its own colour as
    its fifth element (the rainbow case); otherwise the fifth element is
    an alpha applied to `rgb`.
    """
    for rect in rects:
        x, y, w, h = rect[0], rect[1], rect[2], rect[3]
        last = rect[4]
        if rgb is None:
            fill = (*last, 255)
        else:
            fill = (*rgb, int(round(last * 255)))
        x0 = int(round(x * scale + offset))
        y0 = int(round(y * scale + offset))
        x1 = int(round((x + w) * scale + offset))
        y1 = int(round((y + h) * scale + offset))
        # Pillow's rectangle is inclusive of the far edge, so pull it in
        # by one or adjacent tiles overlap and their alphas compound
        # into a visible seam.
        draw.rectangle([x0, y0, x1 - 1, y1 - 1], fill=fill)


def render_mark(
    mark: str,
    rgb: tuple[int, int, int] | None,
    size: int,
    inset: float = 0.0,
) -> Image.Image:
    """Render at `size` px. `inset` shrinks the 96-grid artwork to that
    fraction of the canvas and centres it — used for adaptive safe zones.
    """
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img, "RGBA")

    art = size if inset <= 0 else size * inset
    scale = art / 96
    offset = (size - art) / 2

    if mark == "rainbow":
        _draw(draw, RECTS_RAINBOW, None, scale, offset)
        return img

    base, ink = MARKS[mark]
    _draw(draw, base, rgb, scale, offset)
    _draw(draw, ink, WHITE, scale, offset)
    return img


def write_app(
    app_dir: Path,
    mark: str,
    rgb: tuple[int, int, int] | None,
) -> None:
    res_root = app_dir / "android" / "app" / "src" / "main" / "res"
    if not res_root.exists():
        print(f"skip {app_dir.name}: no Android res root")
        return

    for dpi, size in DPIS.items():
        target = res_root / f"mipmap-{dpi}" / "ic_launcher.png"
        target.parent.mkdir(parents=True, exist_ok=True)
        render_mark(mark, rgb, size).save(target, "PNG")
        print(f"  {target.relative_to(REPO_ROOT)}  {size}x{size}")

    # Adaptive foreground: 96-grid mark scaled to 72 of 108 and centred.
    for dpi, size in ADAPTIVE_DPIS.items():
        target = res_root / f"mipmap-{dpi}" / "ic_launcher_foreground.png"
        target.parent.mkdir(parents=True, exist_ok=True)
        render_mark(mark, rgb, size, inset=72 / 108).save(target, "PNG")
        print(f"  {target.relative_to(REPO_ROOT)}  {size}x{size}")

    anydpi = res_root / "mipmap-anydpi-v26" / "ic_launcher.xml"
    anydpi.parent.mkdir(parents=True, exist_ok=True)
    anydpi.write_text(ADAPTIVE_XML, encoding="utf-8")
    print(f"  {anydpi.relative_to(REPO_ROOT)}")

    background = res_root / "values" / "ic_launcher_background.xml"
    background.parent.mkdir(parents=True, exist_ok=True)
    background.write_text(BACKGROUND_XML, encoding="utf-8")
    print(f"  {background.relative_to(REPO_ROOT)}")


def main() -> None:
    for relative, mark, rgb in APP_DIRS:
        app_dir = REPO_ROOT / relative
        if not app_dir.exists():
            print(f"skip {relative}: no directory")
            continue
        print(relative)
        write_app(app_dir, mark, rgb)


if __name__ == "__main__":
    main()
