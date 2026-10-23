#!/usr/bin/env python3
"""Builds the wallpaper picker index: thumbnails plus a 16-color palette per image, cached."""

import hashlib
import json
import os
import re
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

# Colon-separated folders. Images directly in one are grouped under its name, and images one
# subfolder down under the subfolder's name (each group is a filter tab in the picker).
LIBRARIES = [
    Path(p).expanduser()
    for p in os.environ.get(
        "WALLPAPER_LIBRARY", str(Path.home() / "wallpapers" / "library")
    ).split(":")
    if p
]
SKIP_DIRS = {"Screenshots"}
CACHE = Path.home() / ".cache" / "wallpaper-picker"
THUMBS = CACHE / "thumbs"
PALETTES = CACHE / "palettes.json"
INDEX = CACHE / "index.json"
EXTENSIONS = {".jpg", ".jpeg", ".png", ".gif", ".bmp", ".webp"}


def write_atomic(path: Path, text: str) -> None:
    tmp = path.with_suffix(path.suffix + f".{os.getpid()}.tmp")
    tmp.write_text(text)
    os.replace(tmp, path)


def key_for(path: Path) -> str:
    stat = path.stat()
    return hashlib.sha1(
        f"{path}:{stat.st_mtime_ns}:{stat.st_size}".encode()
    ).hexdigest()


def make_thumb(path: Path, key: str) -> Path:
    thumb = THUMBS / f"{key}.jpg"
    if not thumb.exists():
        tmp = thumb.with_suffix(".tmp.jpg")
        subprocess.run(
            [
                "magick",
                f"{path}[0]",
                "-auto-orient",
                "-thumbnail",
                "640x360^",
                "-gravity",
                "center",
                "-extent",
                "640x360",
                "-quality",
                "85",
                str(tmp),
            ],
            check=True,
            capture_output=True,
        )
        tmp.rename(thumb)
    return thumb


def blend(color: tuple, target: tuple, amount: float) -> tuple:
    return tuple(round(c + (t - c) * amount) for c, t in zip(color, target))


def hex_of(color: tuple) -> str:
    return "#{:02x}{:02x}{:02x}".format(*color)


def luminance(color: tuple) -> float:
    r, g, b = color
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


# A pywal --cols16 style palette from ImageMagick's quantized colors, so the picker needs no pywal:
# 0 background, 1-6 accents dark to light, 7 foreground, 8 muted, 9-14 lighter accents, 15 foreground.
def make_palette(thumb: Path) -> list[str]:
    out = subprocess.run(
        [
            "magick",
            str(thumb),
            "-alpha",
            "off",
            "-resize",
            "64x64!",
            "-colors",
            "8",
            "-format",
            "%c",
            "histogram:info:-",
        ],
        check=True,
        capture_output=True,
        text=True,
    ).stdout
    found = sorted(
        (
            (int(n), tuple(int(h[i : i + 2], 16) for i in (0, 2, 4)))
            for n, h in re.findall(r"^\s*(\d+):.*?#([0-9A-Fa-f]{6})", out, re.MULTILINE)
        ),
        reverse=True,
    )
    if not found:
        raise ValueError("no colors found")
    colors = [c for _, c in found]
    accents = sorted((colors * 6)[:6], key=luminance)
    darkest = min(colors, key=luminance)
    average = tuple(sum(c[i] for c in colors) // len(colors) for i in range(3))
    black, white = (0, 0, 0), (255, 255, 255)
    bg = blend(darkest, black, 0.7)
    fg = blend(average, white, 0.75)
    palette = [
        bg,
        *accents,
        fg,
        blend(bg, white, 0.3),
        *(blend(a, white, 0.25) for a in accents),
        fg,
    ]
    return [hex_of(c) for c in palette]


def main() -> None:
    THUMBS.mkdir(parents=True, exist_ok=True)
    palettes = json.loads(PALETTES.read_text()) if PALETTES.exists() else {}

    files = sorted(
        p
        for lib in LIBRARIES
        for p in [*lib.glob("*"), *lib.glob("*/*")]
        if p.is_file()
        and p.suffix.lower() in EXTENSIONS
        and p.parent.name not in SKIP_DIRS
    )

    def work(path: Path):
        key = key_for(path)
        try:
            thumb = make_thumb(path, key)
            colors = palettes.get(key) or make_palette(thumb)
        except (subprocess.CalledProcessError, OSError, KeyError, ValueError) as err:
            print(f"skip {path}: {err}", file=sys.stderr)
            return None
        return key, {
            "path": str(path),
            "name": path.stem,
            "theme": path.parent.name,
            "thumb": str(thumb),
            "colors": colors,
        }

    with ThreadPoolExecutor(max_workers=4) as pool:
        results = [r for r in pool.map(work, files) if r]

    write_atomic(PALETTES, json.dumps({k: v["colors"] for k, v in results}))
    write_atomic(INDEX, json.dumps([v for _, v in results]))
    print(f"indexed {len(results)} wallpapers")


if __name__ == "__main__":
    main()
