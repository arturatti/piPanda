#!/usr/bin/env python3
"""
Генерация озвучки слогов и слов через ElevenLabs API.
Сначала генерим маленький preview-батч в `_preview/`, проверяем — потом батчим всё.

Запуск:
  set ELEVENLABS_API_KEY=sk_...
  python tool/generate_voice_elevenlabs.py preview            # 3 слога + 1 слово
  python tool/generate_voice_elevenlabs.py syllables          # все слоги
  python tool/generate_voice_elevenlabs.py words              # все слова
  python tool/generate_voice_elevenlabs.py all                # всё подряд

Опц.:
  --voice <id>       — voice id (по умолчанию женский русскоязычный)
  --no-accent        — не подмешивать ударения и удвоения
"""
import argparse
import os
import sys
import time
from pathlib import Path
from typing import Iterable

import requests

API_BASE = "https://api.elevenlabs.io/v1"
DEFAULT_VOICE_ID = "EXAVITQu4vr4xnSDxMaL"  # Sarah (free, default, warm female)
DEFAULT_MODEL = "eleven_multilingual_v2"

ACCENT = "́"

TRANSLIT = {
    'а': 'a', 'б': 'b', 'в': 'v', 'г': 'g', 'д': 'd', 'е': 'e',
    'ё': 'yo', 'ж': 'zh', 'з': 'z', 'и': 'i', 'й': 'j', 'к': 'k',
    'л': 'l', 'м': 'm', 'н': 'n', 'о': 'o', 'п': 'p', 'р': 'r',
    'с': 's', 'т': 't', 'у': 'u', 'ф': 'f', 'х': 'h', 'ц': 'ts',
    'ч': 'ch', 'ш': 'sh', 'щ': 'sch', 'ъ': '', 'ы': 'y', 'ь': '',
    'э': 'e', 'ю': 'yu', 'я': 'ya',
}

VOWELS = set('аеёиоуыэюя')

WORD_STRESS = {
    'аптека': 'апте́ка', 'телега': 'теле́га', 'карета': 'каре́та',
    'ракета': 'раке́та', 'дерево': 'де́рево', 'молоко': 'молоко́',
    'мимоза': 'мимо́за', 'малина': 'мали́на', 'борода': 'бо́рода',
    'овца': 'овца́', 'колесо': 'колесо́', 'забота': 'забо́та',
    'фиалка': 'фиа́лка', 'лама': 'ла́ма', 'лиса': 'лиса́',
    'собака': 'соба́ка', 'курица': 'ку́рица', 'рыба': 'ры́ба',
    'радуга': 'ра́дуга', 'панама': 'пана́ма', 'гора': 'гора́',
    'мама': 'ма́ма', 'дыня': 'ды́ня', 'корова': 'коро́ва',
    'ворона': 'воро́на', 'облако': 'о́блако', 'корона': 'коро́на',
    'сапоги': 'сапоги́', 'сова': 'сова́', 'каша': 'ка́ша',
    'море': 'мо́ре', 'коза': 'коза́', 'луна': 'луна́',
    'рябина': 'ряби́на', 'гитара': 'гита́ра',
}


def translit(s: str) -> str:
    return ''.join(TRANSLIT.get(c, c) for c in s.lower())


def syllable_with_accent(s: str) -> str:
    """Ставим ударение U+0301 на первую гласную: "ма" → "ма́", "ап" → "а́п"."""
    s = s.lower()
    out = []
    accented = False
    for ch in s:
        out.append(ch)
        if ch in VOWELS and not accented:
            out.append(ACCENT)
            accented = True
    return ''.join(out)


def word_with_accent(s: str) -> str:
    return WORD_STRESS.get(s.lower(), s)


def parse_words_file(path: Path) -> tuple[list[str], list[str]]:
    words: list[str] = []
    syllables: dict[str, None] = {}
    for line in path.read_text(encoding='utf-8').splitlines():
        line = line.strip()
        if not line:
            continue
        parts = line.split('|')
        if len(parts) != 3:
            continue
        words.append(parts[0].strip())
        for s in parts[1].strip().split('-'):
            syllables[s.lower()] = None
    return words, list(syllables.keys())


def synth(api_key: str, text: str, out_path: Path,
          voice_id: str = DEFAULT_VOICE_ID,
          model_id: str = DEFAULT_MODEL,
          stability: float = 0.5,
          similarity: float = 0.75,
          style: float = 0.4) -> tuple[bool, str]:
    url = f"{API_BASE}/text-to-speech/{voice_id}"
    headers = {
        "xi-api-key": api_key,
        "Content-Type": "application/json",
        "Accept": "audio/mpeg",
    }
    payload = {
        "text": text,
        "model_id": model_id,
        "voice_settings": {
            "stability": stability,
            "similarity_boost": similarity,
            "style": style,
            "use_speaker_boost": True,
        },
    }
    try:
        r = requests.post(url, headers=headers, json=payload, timeout=60)
        if r.status_code != 200:
            return False, f"HTTP {r.status_code}: {r.text[:200]}"
        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_bytes(r.content)
        return True, "ok"
    except Exception as e:
        return False, str(e)


def gen_batch(api_key: str, items: Iterable[tuple[str, str, Path]],
              voice_id: str, use_accent: bool) -> int:
    """items: iterable of (display_text, raw_key_for_translit, out_path)."""
    ok = 0
    fail = 0
    for raw, key, out in items:
        if out.exists():
            print(f"  [SKIP] {out.name} (already exists)")
            continue
        text = raw if use_accent else raw.replace(ACCENT, '')
        success, msg = synth(api_key, text, out, voice_id=voice_id)
        marker = "OK" if success else "FAIL"
        print(f"  [{marker}] {out.name}  text='{text}'  {msg if not success else ''}")
        if success:
            ok += 1
        else:
            fail += 1
        time.sleep(0.3)
    print(f"  -> ok={ok}, fail={fail}")
    return fail


def cmd_preview(api_key: str, voice_id: str, use_accent: bool, root: Path) -> int:
    out_dir = root / "assets" / "audio" / "_preview"
    syl_samples = ['ма', 'па', 'на']
    word_sample = 'мама'

    items: list[tuple[str, str, Path]] = []
    for s in syl_samples:
        text = syllable_with_accent(s) if use_accent else s
        key = translit(s)
        items.append((text, key, out_dir / f"syl_{key}.mp3"))
    text_w = word_with_accent(word_sample) if use_accent else word_sample
    key_w = translit(word_sample)
    items.append((text_w, key_w, out_dir / f"word_{key_w}.mp3"))

    print(f"Preview: 3 syllables + 1 word -> {out_dir}")
    return gen_batch(api_key, items, voice_id, use_accent)


def cmd_syllables(api_key: str, voice_id: str, use_accent: bool, root: Path) -> int:
    words_file = root / "assets" / "data" / "words.txt"
    _, syls = parse_words_file(words_file)
    out_dir = root / "assets" / "audio" / "syllables"
    items = []
    for s in sorted(syls):
        text = syllable_with_accent(s) if use_accent else s
        key = translit(s)
        items.append((text, key, out_dir / f"{key}.mp3"))
    print(f"Syllables: {len(items)} -> {out_dir}")
    return gen_batch(api_key, items, voice_id, use_accent)


def cmd_words(api_key: str, voice_id: str, use_accent: bool, root: Path) -> int:
    words_file = root / "assets" / "data" / "words.txt"
    words, _ = parse_words_file(words_file)
    out_dir = root / "assets" / "audio" / "words"
    items = []
    for w in sorted(set(words)):
        text = word_with_accent(w) if use_accent else w
        key = translit(w)
        items.append((text, key, out_dir / f"{key}.mp3"))
    print(f"Words: {len(items)} -> {out_dir}")
    return gen_batch(api_key, items, voice_id, use_accent)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("command", choices=["preview", "syllables", "words", "all"])
    parser.add_argument("--voice", default=DEFAULT_VOICE_ID)
    parser.add_argument("--no-accent", action="store_true")
    args = parser.parse_args()

    api_key = os.environ.get("ELEVENLABS_API_KEY")
    if not api_key:
        key_file = Path(__file__).resolve().parent.parent / ".elevenlabs_key"
        if key_file.exists():
            api_key = key_file.read_text(encoding='utf-8').strip()
    if not api_key:
        print("ERROR: set ELEVENLABS_API_KEY env var or create .elevenlabs_key file", file=sys.stderr)
        return 1

    root = Path(__file__).resolve().parent.parent
    use_accent = not args.no_accent

    if args.command == "preview":
        return cmd_preview(api_key, args.voice, use_accent, root)
    if args.command == "syllables":
        return cmd_syllables(api_key, args.voice, use_accent, root)
    if args.command == "words":
        return cmd_words(api_key, args.voice, use_accent, root)
    if args.command == "all":
        f1 = cmd_syllables(api_key, args.voice, use_accent, root)
        f2 = cmd_words(api_key, args.voice, use_accent, root)
        return f1 + f2
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
