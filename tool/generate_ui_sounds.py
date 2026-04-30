#!/usr/bin/env python3
"""
Генерация UI-звуков для piPanda.

Использует additive synthesis + Schroeder reverb (4 comb + 2 allpass)
+ feedback delay. Звук получает "зал" и хвост, не обрезается.

Запуск: python tool/generate_ui_sounds.py
"""
import wave
from pathlib import Path

import numpy as np

SR = 44100


def adsr(n_samples: int, attack: float, decay: float, sustain_level: float,
         release: float) -> np.ndarray:
    n_a = max(1, int(SR * attack))
    n_d = max(1, int(SR * decay))
    n_r = max(1, int(SR * release))
    n_s = max(0, n_samples - n_a - n_d - n_r)
    env = np.concatenate([
        np.linspace(0, 1, n_a, dtype=np.float32),
        np.linspace(1, sustain_level, n_d, dtype=np.float32),
        np.full(n_s, sustain_level, dtype=np.float32),
        np.linspace(sustain_level, 0, n_r, dtype=np.float32),
    ])
    if len(env) > n_samples:
        env = env[:n_samples]
    elif len(env) < n_samples:
        env = np.concatenate([env, np.zeros(n_samples - len(env), dtype=np.float32)])
    return env


def harmonic_tone(freq: float, duration: float,
                  harmonics: list[tuple[float, float]] | None = None) -> np.ndarray:
    if harmonics is None:
        harmonics = [(1.0, 1.0), (2.0, 0.4), (3.0, 0.2), (4.0, 0.1)]
    n = int(SR * duration)
    t = np.arange(n) / SR
    out = np.zeros(n, dtype=np.float32)
    for mul, amp in harmonics:
        out += amp * np.sin(2 * np.pi * freq * mul * t).astype(np.float32)
    out /= max(1.0, sum(amp for _, amp in harmonics))
    return out


def soft_clip(x: np.ndarray, drive: float = 1.2) -> np.ndarray:
    return np.tanh(x * drive) / np.tanh(drive)


def comb_filter(x: np.ndarray, delay_samples: int, feedback: float) -> np.ndarray:
    out = np.zeros(len(x) + delay_samples * 50, dtype=np.float32)
    out[: len(x)] = x
    for i in range(delay_samples, len(out)):
        out[i] += feedback * out[i - delay_samples]
    return out


def allpass_filter(x: np.ndarray, delay_samples: int, feedback: float) -> np.ndarray:
    out = np.zeros(len(x) + delay_samples, dtype=np.float32)
    src = np.zeros(len(x) + delay_samples, dtype=np.float32)
    src[: len(x)] = x
    for i in range(delay_samples, len(out)):
        out[i] = -feedback * src[i] + src[i - delay_samples] + feedback * out[i - delay_samples]
    return out


def schroeder_reverb(dry: np.ndarray, mix: float = 0.45,
                     decay_seconds: float = 1.6) -> np.ndarray:
    """4 comb (Шродер) + 2 allpass — простой "зал". mix = доля wet."""
    feedback = float(np.clip(0.65 + decay_seconds * 0.06, 0.6, 0.92))
    comb_delays_ms = [29.7, 37.1, 41.1, 43.7]
    combs = []
    max_len = 0
    for d in comb_delays_ms:
        c = comb_filter(dry, int(SR * d / 1000), feedback)
        combs.append(c)
        max_len = max(max_len, len(c))
    summed = np.zeros(max_len, dtype=np.float32)
    for c in combs:
        summed[: len(c)] += c
    summed /= 4

    ap1 = allpass_filter(summed, int(SR * 5.0 / 1000), 0.5)
    wet = allpass_filter(ap1, int(SR * 1.7 / 1000), 0.5)

    out_len = max(len(dry), len(wet))
    out = np.zeros(out_len, dtype=np.float32)
    out[: len(dry)] += (1 - mix) * dry
    out[: len(wet)] += mix * wet * 0.5
    return out


def feedback_delay(x: np.ndarray, delay_ms: float = 120.0,
                   feedback: float = 0.35, mix: float = 0.25,
                   tail_seconds: float = 1.0) -> np.ndarray:
    delay_samples = int(SR * delay_ms / 1000)
    n = len(x) + int(SR * tail_seconds)
    out = np.zeros(n, dtype=np.float32)
    src = np.zeros(n, dtype=np.float32)
    src[: len(x)] = x
    for i in range(n):
        wet = 0.0
        if i - delay_samples >= 0:
            wet = src[i - delay_samples] + feedback * out[i - delay_samples]
        out[i] = src[i] + mix * wet
    return out


def lowpass_one_pole(x: np.ndarray, cutoff_hz: float = 6000.0) -> np.ndarray:
    rc = 1.0 / (2 * np.pi * cutoff_hz)
    dt = 1.0 / SR
    alpha = dt / (rc + dt)
    out = np.zeros_like(x)
    prev = 0.0
    for i in range(len(x)):
        prev = prev + alpha * (x[i] - prev)
        out[i] = prev
    return out


def normalize(x: np.ndarray, target_peak: float = 0.85) -> np.ndarray:
    peak = float(np.max(np.abs(x)))
    if peak < 1e-6:
        return x
    return x * (target_peak / peak)


def write_wav(path: Path, samples: np.ndarray) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    samples = np.clip(samples, -1.0, 1.0)
    pcm = (samples * 32767).astype(np.int16)
    with wave.open(str(path), 'wb') as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(SR)
        wf.writeframes(pcm.tobytes())


def gen_correct(out: Path) -> None:
    """Bell: C6 + G6, реверб, delay tail. Длина ~1.6с."""
    notes = [
        (1046.50, 0.0, 0.45),
        (1568.0, 0.18, 0.45),
    ]
    dry = np.zeros(int(SR * 0.7), dtype=np.float32)
    for freq, start, dur in notes:
        tone = harmonic_tone(
            freq=freq, duration=dur,
            harmonics=[(1.0, 1.0), (2.0, 0.55), (3.0, 0.25), (5.0, 0.10)],
        )
        env = adsr(len(tone), attack=0.003, decay=0.04,
                   sustain_level=0.55, release=dur * 0.55)
        tone = tone * env
        s = int(SR * start)
        end = min(s + len(tone), len(dry))
        dry[s:end] += tone[: end - s] * 0.9

    wet = schroeder_reverb(dry, mix=0.5, decay_seconds=1.4)
    delayed = feedback_delay(wet, delay_ms=140, feedback=0.35,
                             mix=0.25, tail_seconds=0.9)
    final = lowpass_one_pole(delayed, cutoff_hz=8000)
    final = normalize(final, target_peak=0.88)
    write_wav(out, final)


def gen_wrong(out: Path) -> None:
    """Мягкий wood-block: E4 → A3, реверб, длинный tail. ~1.4с."""
    notes = [
        (330.0, 0.0, 0.35),
        (220.0, 0.20, 0.50),
    ]
    dry = np.zeros(int(SR * 0.75), dtype=np.float32)
    for freq, start, dur in notes:
        tone = harmonic_tone(
            freq=freq, duration=dur,
            harmonics=[(1.0, 1.0), (2.0, 0.5), (3.0, 0.22), (4.0, 0.10)],
        )
        env = adsr(len(tone), attack=0.004, decay=0.05,
                   sustain_level=0.55, release=dur * 0.45)
        n = len(tone)
        t = np.arange(n) / SR
        decay_curve = np.exp(-2.5 * t).astype(np.float32)
        tone = tone * env * decay_curve
        s = int(SR * start)
        end = min(s + len(tone), len(dry))
        dry[s:end] += tone[: end - s] * 0.85

    wet = schroeder_reverb(dry, mix=0.55, decay_seconds=1.6)
    delayed = feedback_delay(wet, delay_ms=180, feedback=0.30,
                             mix=0.20, tail_seconds=0.8)
    final = lowpass_one_pole(delayed, cutoff_hz=4500)
    final = normalize(final, target_peak=0.85)
    write_wav(out, final)


def gen_success(out: Path) -> None:
    """C-E-G-C ascending arpeggio с реверб-залом, ~2.5с."""
    notes = [
        (523.25, 0.00, 0.45),
        (659.25, 0.10, 0.45),
        (783.99, 0.20, 0.55),
        (1046.50, 0.32, 0.85),
    ]
    dry = np.zeros(int(SR * 1.4), dtype=np.float32)
    for freq, start, dur in notes:
        tone = harmonic_tone(
            freq=freq, duration=dur,
            harmonics=[(1.0, 1.0), (2.0, 0.45), (3.0, 0.20), (4.0, 0.08)],
        )
        env = adsr(len(tone), attack=0.004, decay=0.04,
                   sustain_level=0.6, release=dur * 0.5)
        tone = tone * env
        s = int(SR * start)
        end = min(s + len(tone), len(dry))
        dry[s:end] += tone[: end - s] * 0.7

    wet = schroeder_reverb(dry, mix=0.55, decay_seconds=1.8)
    delayed = feedback_delay(wet, delay_ms=160, feedback=0.40,
                             mix=0.30, tail_seconds=1.1)
    final = lowpass_one_pole(delayed, cutoff_hz=9000)
    final = normalize(final, target_peak=0.88)
    write_wav(out, final)


def main() -> int:
    root = Path(__file__).resolve().parent.parent
    ui_dir = root / "assets" / "audio" / "ui"

    files = [
        (ui_dir / "drop_correct.wav", gen_correct),
        (ui_dir / "drop_wrong.wav", gen_wrong),
        (ui_dir / "success.wav", gen_success),
    ]

    for path, gen in files:
        gen(path)
        size_kb = path.stat().st_size / 1024
        print(f"  -> {path.relative_to(root)} ({size_kb:.1f} KB)")

    print("Done.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
