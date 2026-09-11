#!/usr/bin/env python3
"""Turns the harness's captures into Mac App Store screenshots.

`tool/mac_screenshots.dart` renders each scene at 1024x640 and writes it inside
the app's sandbox container, because a sandboxed app cannot write into the
repository and because Flutter's capture cannot rasterize above 1:1 here (see
the note on `_logicalSize` in that file). This script does the two remaining
steps: scale each image to a size App Store Connect accepts, and move them
somewhere a person — and `scripts/appstore_mac_listing.py` — can get at.

    flutter run -d macos -t tool/mac_screenshots.dart --release
    python3 tool/mac_screenshots_finish.py

The scale is 1.25x of a vector-drawn UI, so the result stays clean; going
straight to 2560x1600 would be a 2.5x upscale and would visibly soften text.
"""

from __future__ import annotations

import shutil
import sys
from pathlib import Path

try:
    from PIL import Image
except ImportError:  # pragma: no cover - environment problem, not logic
    sys.exit("Pillow is required: pip install pillow")

REPO = Path(__file__).resolve().parent.parent
BUNDLE = "com.appsbay.mechanicalEngineeringToolkit"
SOURCE = (
    Path.home() / "Library" / "Containers" / BUNDLE / "Data" / "Documents"
    / "me_toolkit_store"
)
DEST = REPO / "build" / "store" / "macos"

# One of the four sizes App Store Connect accepts for a Mac screenshot. The
# others are 1440x900, 2560x1600 and 2880x1800; all share this 16:10 ratio.
TARGET = (1280, 800)


def main() -> int:
    if not SOURCE.is_dir():
        sys.exit(f"No captures in {SOURCE}.\n"
                 "Run: flutter run -d macos -t tool/mac_screenshots.dart "
                 "--release")

    if DEST.exists():
        shutil.rmtree(DEST)

    total = 0
    for language_dir in sorted(p for p in SOURCE.iterdir() if p.is_dir()):
        out_dir = DEST / language_dir.name
        out_dir.mkdir(parents=True, exist_ok=True)
        for png in sorted(language_dir.glob("*.png")):
            image = Image.open(png).convert("RGB")
            if image.size != TARGET:
                image = image.resize(TARGET, Image.LANCZOS)
            image.save(out_dir / png.name)
            total += 1
        print(f"{language_dir.name}: {len(list(out_dir.glob('*.png')))} images")

    print(f"\n{total} screenshots at {TARGET[0]}x{TARGET[1]} in "
          f"{DEST.relative_to(REPO)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
