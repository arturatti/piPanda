#!/usr/bin/env python3
"""Генерация озвучки через Yandex SpeechKit TTS v3 (premium voices с ролями).

Запуск:
  python tool/generate_voice_yandex.py preview          # 4-6 семплов в _preview_yandex/
  python tool/generate_voice_yandex.py syllables        # все слоги -> assets/audio/syllables/
  python tool/generate_voice_yandex.py words            # все слова -> assets/audio/words/
  python tool/generate_voice_yandex.py all

Опц.:
  --voice marina          (default; alena/jane/marina/oksana/omazh/ermil/zahar)
  --role friendly         (neutral/friendly/strict/whisper/good/evil — зависит от голоса)
  --speed 1.0
"""
import argparse
import base64
import json
import os
import sys
from pathlib import Path

import requests

API_URL = "https://tts.api.cloud.yandex.net/tts/v3/utteranceSynthesis"

DEFAULT_VOICE = "marina"
DEFAULT_ROLE = "friendly"
DEFAULT_SPEED = 1.0
DEFAULT_PITCH = -10

# Substitutions для слогов которые TTS читает неправильно — заменяем на фонетически
# корректное написание. Применяется только к тексту для синтеза, имя файла остаётся
# исходным (ря.wav, не рья.wav).
SYLLABLE_SUBS = {
    "ря": "рья",
    "ал": "алл",
}

VOWELS = set('аеёиоуыэюя')
ACCENT = "́"

TRANSLIT = {
    'а': 'a', 'б': 'b', 'в': 'v', 'г': 'g', 'д': 'd', 'е': 'e',
    'ё': 'yo', 'ж': 'zh', 'з': 'z', 'и': 'i', 'й': 'j', 'к': 'k',
    'л': 'l', 'м': 'm', 'н': 'n', 'о': 'o', 'п': 'p', 'р': 'r',
    'с': 's', 'т': 't', 'у': 'u', 'ф': 'f', 'х': 'h', 'ц': 'ts',
    'ч': 'ch', 'ш': 'sh', 'щ': 'sch', 'ъ': '', 'ы': 'y', 'ь': '',
    'э': 'e', 'ю': 'yu', 'я': 'ya',
}


def translit(s: str) -> str:
    return ''.join(TRANSLIT.get(c, c) for c in s.lower())


def with_excl(text: str, *, apply_subs: bool = False) -> str:
    text = text.lower().rstrip(' .!?')
    if apply_subs:
        text = SYLLABLE_SUBS.get(text, text)
    return text + '!'


def parse_words_file(path: Path):
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


def synth(api_key: str, text: str, voice: str, role: str, speed: float,
          pitch: int = 0) -> bytes:
    hints = [
        {"voice": voice},
        {"role": role},
        {"speed": speed},
    ]
    if pitch:
        hints.append({"pitchShift": int(pitch)})
    payload = {
        "text": text,
        "outputAudioSpec": {
            "containerAudio": {"containerAudioType": "WAV"}
        },
        "hints": hints,
        "loudnessNormalizationType": "LUFS",
    }
    headers = {
        "Authorization": f"Api-Key {api_key}",
        "Content-Type": "application/json",
    }
    r = requests.post(API_URL, headers=headers, json=payload, stream=True, timeout=60)
    if r.status_code != 200:
        raise RuntimeError(f"HTTP {r.status_code}: {r.text[:300]}")

    chunks: list[bytes] = []
    for line in r.iter_lines(decode_unicode=True):
        if not line:
            continue
        try:
            obj = json.loads(line)
        except json.JSONDecodeError:
            continue
        result = obj.get("result", {})
        audio = result.get("audioChunk", {}).get("data")
        if audio:
            chunks.append(base64.b64decode(audio))
    if not chunks:
        raise RuntimeError("No audio chunks in response")
    return b"".join(chunks)


def gen_one(api_key: str, raw_text: str, out: Path, voice: str, role: str,
            speed: float, pitch: int = 0, apply_subs: bool = False) -> tuple[bool, str]:
    if out.exists():
        return True, "skip"
    try:
        text = with_excl(raw_text, apply_subs=apply_subs)
        wav_bytes = synth(api_key, text, voice, role, speed, pitch)
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_bytes(wav_bytes)
        return True, f"text='{text}' size={len(wav_bytes)}"
    except Exception as e:
        return False, f"{type(e).__name__}: {e}"


def cmd_preview(api_key, voice, role, speed, pitch, root):
    out_dir = root / "assets" / "audio" / "_preview_yandex"
    items = [
        # простые
        ("ма",     out_dir / "syl_ma.wav",     False),
        ("па",     out_dir / "syl_pa.wav",     False),
        ("на",     out_dir / "syl_na.wav",     False),
        # сложные с iotated гласной — без и с substitution
        ("ря",     out_dir / "syl_rya_raw.wav", False),
        ("ря",     out_dir / "syl_rya_sub.wav", True),
        ("ня",     out_dir / "syl_nya_raw.wav", False),
        ("ня",     out_dir / "syl_nya_sub.wav", True),
        # мягкая е после согласной (наш "проблемный" сегмент)
        ("те",     out_dir / "syl_te.wav",     False),
        ("ре",     out_dir / "syl_re.wav",     False),
        ("ле",     out_dir / "syl_le.wav",     False),
        # закрытые слоги
        ("ап",     out_dir / "syl_ap.wav",     False),
        ("ов",     out_dir / "syl_ov.wav",     False),
        ("ал",     out_dir / "syl_al.wav",     False),
        # слова контекстные
        ("мама",   out_dir / "word_mama.wav",   False),
        ("рябина", out_dir / "word_ryabina.wav", False),
        ("панама", out_dir / "word_panama.wav", False),
        ("аптека", out_dir / "word_apteka.wav", False),
        ("фиалка", out_dir / "word_fialka.wav", False),
    ]
    print(f"Preview ({voice}/{role}/speed={speed}/pitch={pitch}) -> {out_dir}")
    fail = 0
    for raw, out, subs in items:
        ok, msg = gen_one(api_key, raw, out, voice, role, speed, pitch, apply_subs=subs)
        marker = "OK" if ok else "FAIL"
        sub_tag = " [SUB]" if subs else ""
        print(f"  [{marker}] {out.name}{sub_tag}  {msg}")
        if not ok:
            fail += 1
    print(f"  -> ok={len(items)-fail}, fail={fail}")
    return fail


def collect_all(root):
    """Walk all assets/data/<set>/words.txt — return (words, syllables)."""
    words: dict[str, None] = {}
    syllables: dict[str, None] = {}
    data_root = root / "assets" / "data"
    for set_dir in sorted(data_root.iterdir()):
        wf = set_dir / "words.txt"
        if not wf.exists():
            continue
        ws, ss = parse_words_file(wf)
        for w in ws:
            words[w] = None
        for s in ss:
            syllables[s] = None
    return list(words.keys()), list(syllables.keys())


def cmd_syllables(api_key, voice, role, speed, pitch, root):
    _, syls = collect_all(root)
    out_dir = root / "assets" / "audio" / "syllables"
    fail = 0
    print(f"Syllables (all sets): {len(syls)} ({voice}/{role}/pitch={pitch}) -> {out_dir}")
    for s in sorted(syls):
        out = out_dir / f"{translit(s)}.wav"
        ok, msg = gen_one(api_key, s, out, voice, role, speed, pitch, apply_subs=True)
        marker = "OK" if ok else "FAIL"
        print(f"  [{marker}] {out.name}  {msg}")
        if not ok:
            fail += 1
    print(f"  -> {len(syls) - fail} ok, {fail} failed")
    return fail


def cmd_words(api_key, voice, role, speed, pitch, root):
    words, _ = collect_all(root)
    out_dir = root / "assets" / "audio" / "words"
    words = sorted(set(words))
    fail = 0
    print(f"Words (all sets): {len(words)} ({voice}/{role}/pitch={pitch}) -> {out_dir}")
    for w in words:
        out = out_dir / f"{translit(w)}.wav"
        ok, msg = gen_one(api_key, w, out, voice, role, speed, pitch, apply_subs=False)
        marker = "OK" if ok else "FAIL"
        print(f"  [{marker}] {out.name}  {msg}")
        if not ok:
            fail += 1
    print(f"  -> {len(words) - fail} ok, {fail} failed")
    return fail


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("command", choices=["preview", "syllables", "words", "all"])
    parser.add_argument("--voice", default=DEFAULT_VOICE)
    parser.add_argument("--role", default=DEFAULT_ROLE)
    parser.add_argument("--speed", type=float, default=DEFAULT_SPEED)
    parser.add_argument("--pitch", type=int, default=DEFAULT_PITCH)
    args = parser.parse_args()

    root = Path(__file__).resolve().parent.parent
    key_file = root / ".yandex_key"
    if not key_file.exists():
        print(f"ERROR: {key_file} not found", file=sys.stderr)
        return 1
    api_key = key_file.read_text(encoding="utf-8").strip()
    if not api_key:
        print("ERROR: empty key", file=sys.stderr)
        return 1

    if args.command == "preview":
        return cmd_preview(api_key, args.voice, args.role, args.speed, args.pitch, root)
    if args.command == "syllables":
        return cmd_syllables(api_key, args.voice, args.role, args.speed, args.pitch, root)
    if args.command == "words":
        return cmd_words(api_key, args.voice, args.role, args.speed, args.pitch, root)
    if args.command == "all":
        f1 = cmd_syllables(api_key, args.voice, args.role, args.speed, args.pitch, root)
        f2 = cmd_words(api_key, args.voice, args.role, args.speed, args.pitch, root)
        return f1 + f2
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
