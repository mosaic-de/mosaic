"""Render Mosaic brand SVG marks to Android launcher PNGs.

The SVG files in docs/brand/ all share identical geometry — only the
hex color(s) differ. Rather than depending on an SVG renderer (we tried
cairosvg; cairo isn't on this Windows host), this script reproduces
the rect tessellation directly with Pillow at every Android mipmap
size so we never have to think about rasterizers again.

Two app classes:
  * Single-color apps (wallet, weather, clock, file_manager, main):
    every rect uses the same RGB plus a per-rect alpha for depth.
  * Rainbow apps (launcher): every rect carries its own RGB at full
    opacity, mirroring docs/brand/launcher_mark.svg.

Usage:
    python tools/render_brand_icons.py

Writes PNGs to each app's
    android/app/src/main/res/mipmap-<dpi>/ic_launcher.png

The geometry is the canonical 96x96 viewbox encoded once below; sizes
are scaled per-DPI (mdpi=48px, hdpi=72px, xhdpi=96px, xxhdpi=144px,
xxxhdpi=192px) per Android launcher icon guidelines.
"""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw

# (x, y, w, h, alpha) tuples on a 96x96 grid for single-color marks.
RECTS_TINTED = [
    (6, 6, 40, 40, 1.00),
    (50, 6, 40, 22, 0.70),
    (50, 32, 18, 14, 0.45),
    (72, 32, 18, 14, 0.85),
    (6, 50, 22, 40, 0.55),
    (32, 50, 58, 18, 0.90),
    (32, 72, 26, 18, 0.35),
    (62, 72, 28, 18, 0.65),
]

# (x, y, w, h, rgb) tuples for the launcher rainbow mark — every rect
# is fully opaque, but each carries its own ecosystem accent color.
RECTS_RAINBOW = [
    (6, 6, 40, 40, (0x00, 0xB7, 0xC3)),    # mosaic cyan
    (50, 6, 40, 22, (0xF5, 0x9E, 0x0B)),   # wallet amber
    (50, 32, 18, 14, (0x3B, 0x82, 0xF6)),  # weather blue
    (72, 32, 18, 14, (0x10, 0xB9, 0x81)),  # file_manager green
    (6, 50, 22, 40, (0xEF, 0x44, 0x44)),   # clock red
    (32, 50, 58, 18, (0xA8, 0x55, 0xF7)),  # purple
    (32, 72, 26, 18, (0xEC, 0x48, 0x99)),  # pink
    (62, 72, 28, 18, (0xF5, 0x9E, 0x0B)),  # wallet amber (echo)
]

# Per-app config. Either a single RGB tuple (uses RECTS_TINTED) or the
# string 'rainbow' (uses RECTS_RAINBOW).
APP_DIRS: list[tuple[str, str | tuple[int, int, int]]] = [
    ("examples/wallet_demo", (0xF5, 0x9E, 0x0B)),     # amber
    ("examples/weather_demo", (0x3B, 0x82, 0xF6)),    # blue
    ("apps/mosaic_launcher", "rainbow"),
    ("apps/mosaic_clock", (0xEF, 0x44, 0x44)),         # red
    ("apps/mosaic_file_manager", (0x10, 0xB9, 0x81)),  # green
]

# Android launcher icon sizes per dpi.
DPIS = {
    "mdpi": 48,
    "hdpi": 72,
    "xhdpi": 96,
    "xxhdpi": 144,
    "xxxhdpi": 192,
}

REPO_ROOT = Path(__file__).resolve().parent.parent


def render_tinted(rgb: tuple[int, int, int], size: int) -> Image.Image:
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img, "RGBA")
    scale = size / 96
    for x, y, w, h, alpha in RECTS_TINTED:
        x0 = int(round(x * scale))
        y0 = int(round(y * scale))
        x1 = int(round((x + w) * scale))
        y1 = int(round((y + h) * scale))
        a = int(round(alpha * 255))
        draw.rectangle([x0, y0, x1 - 1, y1 - 1], fill=(*rgb, a))
    return img


def render_rainbow(size: int) -> Image.Image:
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img, "RGBA")
    scale = size / 96
    for x, y, w, h, rgb in RECTS_RAINBOW:
        x0 = int(round(x * scale))
        y0 = int(round(y * scale))
        x1 = int(round((x + w) * scale))
        y1 = int(round((y + h) * scale))
        draw.rectangle([x0, y0, x1 - 1, y1 - 1], fill=(*rgb, 255))
    return img


def write_app(app_dir: Path, mode: str | tuple[int, int, int]) -> None:
    res_root = app_dir / "android" / "app" / "src" / "main" / "res"
    if not res_root.exists():
        print(f"skip {app_dir.name}: no Android res root")
        return
    for dpi, size in DPIS.items():
        target = res_root / f"mipmap-{dpi}" / "ic_launcher.png"
        target.parent.mkdir(parents=True, exist_ok=True)
        if mode == "rainbow":
            img = render_rainbow(size)
        else:
            img = render_tinted(mode, size)
        img.save(target, "PNG")
        print(f"wrote {target.relative_to(REPO_ROOT)}  {size}x{size}")


def main() -> None:
    for relative, mode in APP_DIRS:
        app_dir = REPO_ROOT / relative
        if not app_dir.exists():
            print(f"skip {relative}: no directory")
            continue
        write_app(app_dir, mode)


if __name__ == "__main__":
    main()
