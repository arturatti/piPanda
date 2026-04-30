#!/usr/bin/env python3
"""Генерация картинок через Pollinations.ai (бесплатно, без ключа, FLUX под капотом).
Запасной вариант когда лимиты Gemini кончились.

Запуск:
  python tool/generate_images_pollinations.py             # missing only
  python tool/generate_images_pollinations.py --all       # все 35
  python tool/generate_images_pollinations.py --only mama,luna
  python tool/generate_images_pollinations.py --to _alt   # в подпапку, не перезаписывая
"""
import argparse
import re
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path
from urllib.parse import quote

import requests

ROOT = Path(__file__).resolve().parent.parent
IMAGES_DIR = ROOT / "assets" / "images" / "words"
PROMPT_MD = ROOT / ".info" / "image_prompt.md"

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


def build_url(obj_en: str, seed: int) -> str:
    prompt = f"A {obj_en}, {STYLE}"
    return f"{API_BASE}/{quote(prompt)}?width={WIDTH}&height={HEIGHT}&model={MODEL}&nologo=true&seed={seed}"


def fetch(url: str, out: Path, max_retries: int = 10) -> tuple[bool, str]:
    import time
    last_err = ""
    for attempt in range(max_retries):
        try:
            r = requests.get(url, timeout=180)
            if r.status_code == 429:
                wait = 15 + attempt * 15  # 15, 30, 45, 60... до 165 сек
                last_err = f"HTTP 429 (retry {attempt+1}/{max_retries} after {wait}s)"
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
    parser.add_argument("--to", default="", help="subfolder under words/ (e.g. _alt)")
    parser.add_argument("--seed", type=int, default=42)
    parser.add_argument("--workers", type=int, default=8, help="parallel workers")
    args = parser.parse_args()

    if not PROMPT_MD.exists():
        print(f"ERROR: {PROMPT_MD} not found", file=sys.stderr)
        return 1

    rows = parse_table(PROMPT_MD.read_text(encoding="utf-8"))
    print(f"Parsed {len(rows)} rows")

    if args.only:
        wanted = set(s.strip().replace(".png", "") for s in args.only.split(","))
        rows = [r for r in rows if r[1].replace(".png", "") in wanted]

    out_dir = IMAGES_DIR / args.to if args.to else IMAGES_DIR

    todo = []
    skipped = 0
    for word_ru, filename, obj_en in rows:
        out = out_dir / filename
        if out.exists() and not args.all:
            skipped += 1
            continue
        todo.append((word_ru, filename, obj_en, out))

    print(f"Generating {len(todo)} images with {args.workers} parallel workers (skipped {skipped} existing)")

    ok = 0
    fail = 0

    def task(item):
        word_ru, filename, obj_en, out = item
        url = build_url(obj_en, args.seed)
        return word_ru, filename, fetch(url, out)

    with ThreadPoolExecutor(max_workers=args.workers) as ex:
        futures = [ex.submit(task, t) for t in todo]
        for fut in as_completed(futures):
            word_ru, filename, (success, msg) = fut.result()
            marker = "OK" if success else "FAIL"
            print(f"  [{marker}] {filename}  ({word_ru})  {msg}", flush=True)
            if success:
                ok += 1
            else:
                fail += 1

    print(f"\nDone. ok={ok}, fail={fail}, skipped={skipped}")
    return 0 if fail == 0 else 2


if __name__ == "__main__":
    raise SystemExit(main())
