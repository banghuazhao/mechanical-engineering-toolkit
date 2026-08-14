#!/usr/bin/env python3
"""Rebuilds the CJK fallback fonts the PDF export embeds.

`fonts/NotoSans-{Regular,Bold}.ttf` cover Latin, Greek and Cyrillic, which is
everything the `en`/`de`/`fr` locales need. The `ja`/`zh`/`zh_HK` locales need
roughly a thousand Han characters and kana on top of that, and the full Noto
Sans CJK faces are 6-11 MB each -- far too heavy to ship for the handful of
labels a report actually draws.

So we subset. Every string a report can contain is static: localized labels
live in `lib/l10n/*.arb`, and formula steps are literals in `lib/`. This script
collects the characters those two sources use and cuts each source face down to
just those, producing assets in the low hundreds of kilobytes.

Run it after adding or changing any CJK string, then commit the rebuilt fonts:

    python3 tool/subset_pdf_fonts.py \
        --source-sc /path/to/NotoSansSC-Regular.ttf \
        --source-jp /path/to/NotoSansJP-Regular.ttf

Both source faces are OFL-1.1 (see fonts/OFL.txt) and are downloadable from
https://fonts.google.com/noto. `pip install fonttools` provides `pyftsubset`,
which does the actual cutting.
"""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
L10N = REPO / "lib" / "l10n"
FONTS = REPO / "fonts"

# Which .arb files each subset has to serve. zh_HK is Traditional, but Noto
# Sans SC carries the traditional forms it needs, so one SC-derived face covers
# both Chinese locales; ja gets its own so kanji keep Japanese glyph forms.
TARGETS = {
    "sc": ("NotoSansCJKsc-Subset.ttf", ["intl_zh.arb", "intl_zh_HK.arb"]),
    "jp": ("NotoSansCJKjp-Subset.ttf", ["intl_ja.arb"]),
}

# Symbols worth carrying even when nothing references them today. The base Noto
# Sans lacks the Mathematical Operators block, so these fall through to the CJK
# faces; keeping them means a new formula that uses one renders as written
# instead of silently going missing.
EXTRA = set("√≈≤≥≠∑∫∞∂±×÷·°′″µΩ−–—…‰⌀∅⟨⟩")


def chars_in_arb(path: Path) -> set[str]:
    """Every character in an .arb file's translated values.

    Keys and `@`-prefixed metadata are tooling, not rendered text, so they are
    skipped -- including them would pull ASCII noise into the subset.
    """
    data = json.loads(path.read_text(encoding="utf-8"))
    return {
        c
        for key, value in data.items()
        if isinstance(value, str) and not key.startswith("@")
        for c in value
    }


def chars_in_sources() -> set[str]:
    """Every non-ASCII character appearing in the hand-written Dart sources.

    Formula steps ("τ = T·r/J", "d⁴") are string literals rather than
    translations, so the .arb files alone would miss them. Scanning whole files
    over-collects a little -- comments and identifiers come along too -- which
    costs a few glyphs and guarantees nothing is missed.

    `lib/generated/intl/messages_*.dart` is skipped: it is compiled from the
    .arb files, so scanning it would fold every locale's characters into every
    subset and leave the two faces identical.
    """
    found: set[str] = set()
    for dart in (REPO / "lib").rglob("*.dart"):
        if dart.match("generated/intl/messages_*.dart"):
            continue
        found.update(c for c in dart.read_text(encoding="utf-8") if ord(c) > 0x7F)
    return found


def subset(source: Path, output: Path, text: set[str]) -> None:
    # Sorted so an unchanged character set produces an identical file and the
    # rebuilt font does not show up as a spurious diff.
    ordered = "".join(sorted(text))
    subprocess.run(
        [
            sys.executable,
            "-m",
            "fontTools.subset",
            str(source),
            f"--text={ordered}",
            f"--output-file={output}",
            # The PDF writer positions every glyph itself and does no shaping,
            # so the layout tables are dead weight here.
            "--layout-features=",
            "--no-hinting",
            "--drop-tables+=DSIG",
            "--name-IDs=*",
        ],
        check=True,
    )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-sc", type=Path, required=True)
    parser.add_argument("--source-jp", type=Path, required=True)
    args = parser.parse_args()

    sources = {"sc": args.source_sc, "jp": args.source_jp}
    shared = chars_in_sources() | EXTRA

    for key, (name, arbs) in TARGETS.items():
        source = sources[key]
        if not source.is_file():
            print(f"error: {source} not found", file=sys.stderr)
            return 1

        text = set(shared)
        for arb in arbs:
            text |= chars_in_arb(L10N / arb)
        # ASCII is always drawn by the base Noto Sans, so carrying it here
        # would only pad the file.
        text = {c for c in text if ord(c) > 0x7F}

        output = FONTS / name
        subset(source, output, text)
        size = output.stat().st_size
        print(f"{name}: {len(text)} characters, {size / 1024:.0f} KB")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
