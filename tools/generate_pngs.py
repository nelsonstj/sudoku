#!/usr/bin/env python3
"""
Simple helper to rasterize `assets/icons/app_icon.svg` into multiple PNG sizes.
Requires: cairosvg (pip install cairosvg)
Usage:
  python tools/generate_pngs.py
Outputs to: assets/icons/generated/
"""
import os
import sys
from pathlib import Path

try:
    from cairosvg import svg2png
except Exception as e:
    print("Missing dependency: cairosvg is required. Install with: pip install cairosvg")
    sys.exit(1)

SVG = Path('assets/icons/app_icon.svg')
OUT = Path('assets/icons/generated')
SIZES = [1024, 512, 384, 192, 144, 96, 72, 48, 36]

if not SVG.exists():
    print(f"SVG source not found: {SVG.resolve()}")
    sys.exit(1)

OUT.mkdir(parents=True, exist_ok=True)

for s in SIZES:
    out_file = OUT / f'app_icon_{s}.png'
    try:
        svg2png(url=str(SVG), write_to=str(out_file), output_width=s, output_height=s)
        print(f"Wrote: {out_file} ({s}x{s})")
    except Exception as ex:
        print(f"Failed to render {s}x{s}: {ex}")

print("Done. You can now use the generated PNGs (assets/icons/generated/) for launcher icons or other targets.")
