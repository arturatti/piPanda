#!/usr/bin/env python3
"""
Удаление фона у PNG-картинок через rembg + ONNX Runtime GPU (BiRefNet-general).
Веса моделей кэшируются в D:\\Soft\\rembg\\u2net_cache.
Использует CUDA через onnxruntime-gpu + nvidia-cudnn-cu12 (pip wheels).

Запуск:
  python tool/remove_bg.py                 # src=assets/images/words, out=src/_nobg
  python tool/remove_bg.py <src> <out>     # явные пути
"""
import os
import sys
from pathlib import Path

# 1) кэш моделей на D:
os.environ.setdefault("U2NET_HOME", r"D:\Soft\rembg\u2net_cache")

# 2) DLL-пути для onnxruntime-gpu — инжектим в PATH ДО импорта onnxruntime,
# иначе LoadLibrary внутри onnxruntime не находит cudnn64_9.dll.
def _inject_nvidia_paths() -> None:
    site_pkgs = Path(sys.prefix) / "Lib" / "site-packages"
    user_site = Path.home() / "AppData/Roaming/Python/Python313/site-packages"
    nvidia_subdirs: list[str] = []
    for base in (site_pkgs, user_site):
        nv = base / "nvidia"
        if not nv.exists():
            continue
        for sub in nv.iterdir():
            bin_dir = sub / "bin"
            if bin_dir.exists():
                nvidia_subdirs.append(str(bin_dir))
    if nvidia_subdirs:
        os.environ["PATH"] = os.pathsep.join(nvidia_subdirs) + os.pathsep + os.environ.get("PATH", "")
        if hasattr(os, "add_dll_directory"):
            for p in nvidia_subdirs:
                try:
                    os.add_dll_directory(p)
                except Exception:
                    pass


_inject_nvidia_paths()

from PIL import Image  # noqa: E402
from rembg import remove, new_session  # noqa: E402

ALPHA_MATTING = False
MODEL = "birefnet-general"
PROVIDERS = ["CUDAExecutionProvider", "CPUExecutionProvider"]


def process_one(src: Path, dst: Path, session) -> tuple[bool, str]:
    """ВАЖНО: пишет результат в dst (другой путь), исходник src не трогает."""
    try:
        input_bytes = src.read_bytes()
        if ALPHA_MATTING:
            out_bytes = remove(
                input_bytes,
                session=session,
                alpha_matting=True,
                alpha_matting_foreground_threshold=240,
                alpha_matting_background_threshold=10,
                alpha_matting_erode_size=10,
            )
        else:
            out_bytes = remove(input_bytes, session=session)
        dst.parent.mkdir(parents=True, exist_ok=True)
        dst.write_bytes(out_bytes)
        return True, "ok"
    except Exception as e:
        return False, str(e)


def main() -> int:
    root = Path(__file__).resolve().parent.parent
    src_dir = Path(sys.argv[1]) if len(sys.argv) > 1 else root / "assets" / "images" / "words"
    out_dir = Path(sys.argv[2]) if len(sys.argv) > 2 else src_dir / "_nobg"

    if not src_dir.exists():
        print(f"Not found: {src_dir}", file=sys.stderr)
        return 1
    if src_dir.resolve() == out_dir.resolve():
        print("ERROR: src and out must differ (no in-place overwrite).", file=sys.stderr)
        return 1

    pngs = sorted(p for p in src_dir.glob("*.png") if not p.is_relative_to(out_dir))
    if not pngs:
        print(f"No PNG files in {src_dir}")
        return 0

    print(f"Source: {src_dir}")
    print(f"Output: {out_dir}")
    print(f"Cache:  {os.environ.get('U2NET_HOME')}")
    print(f"Loading model {MODEL} with providers={PROVIDERS}...")
    session = new_session(MODEL, providers=PROVIDERS)
    try:
        active = session.inner_session.get_providers()
        print(f"Active providers: {active}")
    except Exception:
        pass
    print(f"Processing {len(pngs)} files...\n")

    ok = 0
    fail = 0
    for png in pngs:
        out = out_dir / png.name
        success, msg = process_one(png, out, session)
        marker = "OK" if success else "FAIL"
        print(f"  [{marker}] {png.name}  {msg if not success else ''}")
        if success:
            ok += 1
        else:
            fail += 1

    print(f"\nDone. {ok} ok, {fail} failed.")
    print(f"Когда проверишь результат — переложи нужные из {out_dir} в {src_dir}.")
    return 0 if fail == 0 else 2


if __name__ == "__main__":
    raise SystemExit(main())
