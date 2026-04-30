#!/usr/bin/env python3
"""Генерация 15 картинок темы Динозавры через Pollinations.ai FLUX."""
import argparse
import re
import sys
import time
from pathlib import Path
from urllib.parse import quote

import requests

ROOT = Path(__file__).resolve().parent.parent
IMAGES_DIR = ROOT / "assets" / "images" / "words" / "dinosaurs"
PROMPT_MD = ROOT / ".info" / "image_prompt_dinosaurs.md"

API_BASE = "https://image.pollinations.ai/prompt"
MODEL = "flux"
WIDTH = 1024
HEIGHT = 1024

STYLE = (
    "flat illustration for children, soft rounded shapes, "
    "warm pastel color palette, gentle outline, friendly cute style, "
    "single object centered on plain white background, no text, no shadows on background, "
    "picture book style, age 4-7, minimalist composition, clean vector look"
)


def parse_table(md: str) -> list[tuple[str, str, str]]:
    rows = []
    for line in md.splitlines():
        m = re.match(r"^\|\s*([А-Яа-яЁё][А-Яа-яЁё ]+?)\s*\|\s*([a-z_]+\.png)\s*\|\s*(.+?)\s*\|\s*$", line)
        if m:
            rows.append((m.group(1).strip(), m.group(2).strip(), m.group(3).strip()))
    return rows


def fetch(url: str, out: Path, max_retries: int = 8) -> tuple[bool, str]:
    last_err = ""
    for attempt in range(max_retries):
        try:
            r = requests.get(url, timeout=240)
            if r.status_code == 429:
                wait = 15 + attempt * 15
                print(f"    HTTP 429 retry {attempt+1}/{max_retries} after {wait}s")
                time.sleep(wait)
                continue
            if r.status_code != 200:
                if r.status_code in (502, 503, 504):
                    time.sleep(10)
                    continue
                return False, f"HTTP {r.status_code}"
            if len(r.content) < 1000:
                return False, f"too small: {len(r.content)} bytes"
            out.parent.mkdir(parents=True, exist_ok=True)
            out.write_bytes(r.content)
            return True, f"size={len(r.content)}"
        except Exception as e:
            last_err = f"{type(e).__name__}: {e}"
            time.sleep(5)
    return False, last_err


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--all", action="store_true")
    parser.add_argument("--only", default="")
    args = parser.parse_args()

    rows = parse_table(PROMPT_MD.read_text(encoding="utf-8"))
    print(f"Parsed {len(rows)} rows from {PROMPT_MD.name}")

    if args.only:
        wanted = set(s.strip().replace(".png", "") for s in args.only.split(","))
        rows = [r for r in rows if r[1].replace(".png", "") in wanted]
        print(f"Filtered to {len(rows)}: {[r[1] for r in rows]}")

    ok = 0
    fail = 0
    skipped = 0
    for word_ru, filename, obj_en in rows:
        out = IMAGES_DIR / filename
        if out.exists() and not args.all:
            skipped += 1
            continue
        seed = abs(hash(filename)) % 100000
        full_prompt = f"{obj_en}, {STYLE}"
        url = f"{API_BASE}/{quote(full_prompt)}?width={WIDTH}&height={HEIGHT}&model={MODEL}&nologo=true&seed={seed}"
        success, msg = fetch(url, out)
        marker = "OK" if success else "FAIL"
        print(f"  [{marker}] {filename}  ({word_ru})  seed={seed}  {msg}")
        if success:
            ok += 1
        else:
            fail += 1
        time.sleep(2.0)

    print(f"\nDone. ok={ok}, fail={fail}, skipped={skipped}")
    return 0 if fail == 0 else 2


if __name__ == "__main__":
    raise SystemExit(main())
