#!/usr/bin/env python3
"""Генерация маскота piPanda через Google Gemini Image (Nano Banana 2).
4 позы маленькой панды для разных мест в UI."""
import argparse
import os
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT_DIR = ROOT / "assets" / "images" / "mascot"
KEY_FILE = ROOT / ".gemini_key"

MODEL = "gemini-3.1-flash-image-preview"

STYLE = (
    "flat illustration for children, soft rounded shapes, warm pastel palette, "
    "gentle outline, friendly cute style, picture book aesthetic, age 4-7, "
    "minimalist composition, clean vector look, single character centered on plain white background, "
    "no text, no shadow, full body visible, 1024x1024"
)

POSES = {
    "panda_idle.png": (
        "A cute baby panda standing upright, smiling softly, holding a small green bamboo leaf, "
        "looking forward with big friendly eyes, calm and welcoming pose"
    ),
    "panda_cheer.png": (
        "A cute baby panda jumping with joy, both arms raised up high in celebration, "
        "wide happy smile, eyes closed in delight, confetti-like sparkles around (small), "
        "energetic happy pose"
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


def generate(client, prompt: str, out: Path) -> tuple[bool, str]:
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
    parser.add_argument("--only", default="", help="comma-separated names (idle,cheer,smile,think)")
    args = parser.parse_args()

    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key and KEY_FILE.exists():
        api_key = KEY_FILE.read_text(encoding="utf-8").strip()
    if not api_key:
        print("ERROR: no API key (.gemini_key or GEMINI_API_KEY)", file=sys.stderr)
        return 1
    os.environ["GEMINI_API_KEY"] = api_key

    only = set()
    if args.only:
        only = {f"panda_{s.strip()}.png" for s in args.only.split(",")}

    targets = [(k, v) for k, v in POSES.items() if not only or k in only]
    print(f"Will generate {len(targets)} pose(s)")

    from google import genai
    client = genai.Client(api_key=api_key)

    ok = 0
    fail = 0
    skipped = 0
    for filename, base_prompt in targets:
        out = OUT_DIR / filename
        if out.exists() and not args.all:
            skipped += 1
            print(f"  [SKIP] {filename} (exists, use --all to overwrite)")
            continue
        prompt = f"{base_prompt}, {STYLE}, PNG"
        success, msg = generate(client, prompt, out)
        marker = "OK" if success else "FAIL"
        print(f"  [{marker}] {filename}  {msg}")
        if success:
            ok += 1
        else:
            fail += 1
        time.sleep(1.0)

    print(f"\nDone. ok={ok}, fail={fail}, skipped={skipped}")
    return 0 if fail == 0 else 2


if __name__ == "__main__":
    raise SystemExit(main())
