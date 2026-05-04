"""Render Mosaic brand SVG marks to Android launcher PNGs.

The SVG files in docs/brand/ all share identical geometry — only the
hex color differs. Rather than depending on an SVG renderer (we tried
cairosvg; cairo isn't on this Windows host), this script reproduces
the rect tessellation directly with Pillow at every Android mipmap
size so we never have to think about rasterizers again.

Usage:
    python tools/render_brand_icons.py

Writes PNGs to:
    examples/<app>_demo/android/app/src/main/res/mipmap-<dpi>/ic_launcher.png

The geometry is the canonical 96x96 viewbox encoded once below; sizes
are scaled per-DPI (mdpi=48px, hdpi=72px, xhdpi=96px, xxhdpi=144px,
xxxhdpi=192px) per Android launcher icon guidelines.
"""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw

# (x, y, w, h, alpha) tuples on a 96x96 grid.
RECTS = [
    (6, 6, 40, 40, 1.00),
    (50, 6, 40, 22, 0.70),
    (50, 32, 18, 14, 0.45),
    (72, 32, 18, 14, 0.85),
    (6, 50, 22, 40, 0.55),
    (32, 50, 58, 18, 0.90),
    (32, 72, 26, 18, 0.35),
    (62, 72, 28, 18, 0.65),
]

# Per-app color (matches docs/brand/*.svg).
APPS = {
    "wallet_demo": (0xF5, 0x9E, 0x0B),   # amber
    "weather_demo": (0x3B, 0x82, 0xF6),  # blue
}

# Android launcher icon sizes per dpi.
DPIS = {
    "mdpi": 48,
    "hdpi": 72,
    "xhdpi": 96,
    "xxhdpi": 144,
    "xxxhdpi": 192,
}

REPO_ROOT = Path(__file__).resolve().parent.parent


def render_icon(rgb: tuple[int, int, int], size: int) -> Image.Image:
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img, "RGBA")
    scale = size / 96
    for x, y, w, h, alpha in RECTS:
        x0 = int(round(x * scale))
        y0 = int(round(y * scale))
        x1 = int(round((x + w) * scale))
        y1 = int(round((y + h) * scale))
        a = int(round(alpha * 255))
        draw.rectangle([x0, y0, x1 - 1, y1 - 1], fill=(*rgb, a))
    return img


def write_app(app_dir: Path, rgb: tuple[int, int, int]) -> None:
    res_root = app_dir / "android" / "app" / "src" / "main" / "res"
    if not res_root.exists():
        raise SystemExit(f"missing res root: {res_root}")
    for dpi, size in DPIS.items():
        target = res_root / f"mipmap-{dpi}" / "ic_launcher.png"
        target.parent.mkdir(parents=True, exist_ok=True)
        render_icon(rgb, size).save(target, "PNG")
        print(f"wrote {target.relative_to(REPO_ROOT)}  {size}x{size}")


def main() -> None:
    for app, rgb in APPS.items():
        app_dir = REPO_ROOT / "examples" / app
        if not app_dir.exists():
            print(f"skip {app}: no directory")
            continue
        write_app(app_dir, rgb)


if __name__ == "__main__":
    main()
