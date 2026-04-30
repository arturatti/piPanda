#!/usr/bin/env python3
"""Генерация картинок слов через Google Gemini Image (Nano Banana 2).
Читает image_prompt.md → находит таблицу объектов → генерит missing.

Запуск:
  python tool/generate_images_gemini.py            # missing only
  python tool/generate_images_gemini.py --all      # все 35, перезаписать существующие
  python tool/generate_images_gemini.py --only apteka,malina  # конкретные
"""
import argparse
import os
import re
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
IMAGES_DIR = ROOT / "assets" / "images" / "words"
PROMPT_MD = ROOT / ".info" / "image_prompt.md"
KEY_FILE = ROOT / ".gemini_key"

MODEL = "gemini-3.1-flash-image-preview"

# Универсальный стиль из image_prompt.md
STYLE = (
    "flat illustration for children, soft rounded shapes, "
    "warm pastel color palette, gentle outline, friendly cute style, "
    "single object centered on plain white background, no text, no shadows on background, "
    "picture book style, age 4-7, minimalist composition, clean vector look, 1024x1024"
)


def parse_table(md: str) -> list[tuple[str, str, str]]:
    """Парсит таблицу |Слово|Файл|Объект| из markdown."""
    rows = []
    for line in md.splitlines():
        m = re.match(r"^\|\s*([А-Яа-яЁё][А-Яа-яЁё ]+?)\s*\|\s*([a-z_]+\.png)\s*\|\s*(.+?)\s*\|\s*$", line)
        if m:
            rows.append((m.group(1).strip(), m.group(2).strip(), m.group(3).strip()))
    return rows


def build_prompt(obj_en: str) -> str:
    return f"A {obj_en}, {STYLE}, PNG"


def generate(client, name: str, prompt: str, out: Path) -> tuple[bool, str]:
    try:
        resp = client.models.generate_content(model=MODEL, contents=[prompt])
        for cand in resp.candidates or []:
            for part in cand.content.parts or []:
                inline = getattr(part, "inline_data", None)
                if inline and inline.data:
                    out.parent.mkdir(parents=True, exist_ok=True)
                    out.write_bytes(inline.data)
                    return True, f"size={len(inline.data)}"
        return False, "no inline_data in response"
    except Exception as e:
        return False, f"{type(e).__name__}: {e}"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--all", action="store_true", help="regenerate all (overwrite)")
    parser.add_argument("--only", default="", help="comma-separated list of file basenames (e.g. malina,apteka)")
    args = parser.parse_args()

    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key and KEY_FILE.exists():
        api_key = KEY_FILE.read_text(encoding="utf-8").strip()
    if not api_key:
        print("ERROR: no API key (.gemini_key or GEMINI_API_KEY)", file=sys.stderr)
        return 1
    os.environ["GEMINI_API_KEY"] = api_key

    if not PROMPT_MD.exists():
        print(f"ERROR: {PROMPT_MD} not found", file=sys.stderr)
        return 1

    rows = parse_table(PROMPT_MD.read_text(encoding="utf-8"))
    if not rows:
        print(f"ERROR: no rows parsed from {PROMPT_MD}", file=sys.stderr)
        return 1
    print(f"Parsed {len(rows)} rows from prompt md")

    if args.only:
        wanted = set(s.strip().replace(".png", "") for s in args.only.split(","))
        rows = [r for r in rows if r[1].replace(".png", "") in wanted]
        print(f"Filtered to {len(rows)}: {[r[1] for r in rows]}")

    from google import genai
    client = genai.Client(api_key=api_key)

    ok = 0
    fail = 0
    skipped = 0
    for word_ru, filename, obj_en in rows:
        out = IMAGES_DIR / filename
        if out.exists() and not args.all:
            skipped += 1
            continue
        prompt = build_prompt(obj_en)
        success, msg = generate(client, filename, prompt, out)
        marker = "OK" if success else "FAIL"
        print(f"  [{marker}] {filename}  ({word_ru})  {msg}")
        if success:
            ok += 1
        else:
            fail += 1
        time.sleep(1.0)

    print(f"\nDone. ok={ok}, fail={fail}, skipped={skipped}")
    return 0 if fail == 0 else 2


if __name__ == "__main__":
    raise SystemExit(main())
