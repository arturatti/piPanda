#!/usr/bin/env python3
"""Генерация маскота piPanda через Pollinations.ai FLUX (бесплатно).
4 позы маленькой панды для разных мест в UI.
"""
import argparse
import sys
import time
from pathlib import Path
from urllib.parse import quote

import requests

ROOT = Path(__file__).resolve().parent.parent
OUT_DIR = ROOT / "assets" / "images" / "mascot"

API_BASE = "https://image.pollinations.ai/prompt"
MODEL = "flux"
WIDTH = 1024
HEIGHT = 1024

STYLE = (
    "flat illustration for children, soft rounded shapes, warm pastel palette, "
    "gentle outline, friendly cute style, picture book aesthetic, age 4-7, "
    "minimalist composition, clean vector look, single character centered on plain white background, "
    "no text, no shadow, full body visible"
)

POSES = {
    "panda_idle.png": (
        "A cute baby panda standing upright, smiling softly, holding a small green bamboo leaf, "
        "looking forward with big friendly eyes, calm and welcoming pose"
    ),
    "panda_cheer.png": (
        "A cute baby panda jumping with joy, both arms raised up high in celebration, "
        "wide happy smile, eyes closed in delight, energetic happy pose"
    ),
    "panda_smile.png": (
        "A cute baby panda sitting calmly with a gentle warm smile, "
        "holding paws together near chest, soft proud expression, eyes slightly squinting in joy"
    ),
    "panda_think.png": (
        "A cute baby panda standing and tilting head, one paw to chin in a thinking pose, "
        "soft curious expression, eyes looking up to the side, neutral encouraging mood"
    ),
}

SEEDS = {
    "panda_idle.png": 7311,
    "panda_cheer.png": 9842,
    "panda_smile.png": 5213,
    "panda_think.png": 3456,
}


def build_url(prompt: str, seed: int) -> str:
    full = f"{prompt}, {STYLE}"
    return f"{API_BASE}/{quote(full)}?width={WIDTH}&height={HEIGHT}&model={MODEL}&nologo=true&seed={seed}"


def fetch(url: str, out: Path, max_retries: int = 8) -> tuple[bool, str]:
    last_err = ""
    for attempt in range(max_retries):
        try:
            r = requests.get(url, timeout=180)
            if r.status_code == 429:
                wait = 15 + attempt * 15
                last_err = f"HTTP 429 (retry {attempt+1}/{max_retries} after {wait}s)"
                print(f"    {last_err}")
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

    only = set()
    if args.only:
        only = {f"panda_{s.strip()}.png" for s in args.only.split(",")}

    targets = [(k, v) for k, v in POSES.items() if not only or k in only]
    print(f"Will generate {len(targets)} pose(s) via Pollinations FLUX")

    ok = 0
    fail = 0
    skipped = 0
    for filename, base_prompt in targets:
        out = OUT_DIR / filename
        if out.exists() and not args.all:
            skipped += 1
            print(f"  [SKIP] {filename} exists")
            continue
        seed = SEEDS.get(filename, 1234)
        url = build_url(base_prompt, seed)
        success, msg = fetch(url, out)
        marker = "OK" if success else "FAIL"
        print(f"  [{marker}] {filename}  seed={seed}  {msg}")
        if success:
            ok += 1
        else:
            fail += 1
        time.sleep(2.0)

    print(f"\nDone. ok={ok}, fail={fail}, skipped={skipped}")
    return 0 if fail == 0 else 2


if __name__ == "__main__":
    raise SystemExit(main())
