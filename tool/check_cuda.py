#!/usr/bin/env python3
"""Проверка что onnxruntime-gpu запускает CUDAExecutionProvider."""
import os
import sys
from pathlib import Path

# Найти nvidia/* DLL папки и добавить в PATH ДО импорта onnxruntime
def _inject_nvidia_paths():
    site_pkgs = Path(sys.prefix) / "Lib" / "site-packages"
    user_site = Path.home() / "AppData/Roaming/Python/Python313/site-packages"
    bases = [site_pkgs, user_site]
    nvidia_subdirs = []
    for base in bases:
        nv = base / "nvidia"
        if nv.exists():
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
                except Exception as e:
                    print(f"  add_dll_directory({p}) failed: {e}")
    print(f"Injected {len(nvidia_subdirs)} nvidia bin dirs into PATH")
    for p in nvidia_subdirs:
        print(f"  {p}")
    return nvidia_subdirs

_inject_nvidia_paths()

import onnxruntime as ort
print(f"onnxruntime version: {ort.__version__}")
print(f"build info device: {ort.get_device()}")
print(f"available providers: {ort.get_available_providers()}")

# Создаём минимальную dummy-сессию
import numpy as np
import io
try:
    import onnx
    from onnx import helper, TensorProto
    X = helper.make_tensor_value_info("X", TensorProto.FLOAT, [1, 3])
    Y = helper.make_tensor_value_info("Y", TensorProto.FLOAT, [1, 3])
    node = helper.make_node("Identity", ["X"], ["Y"])
    g = helper.make_graph([node], "g", [X], [Y])
    m = helper.make_model(g, opset_imports=[helper.make_opsetid("", 18)])
    m.ir_version = 9
    buf = io.BytesIO()
    onnx.save_model(m, buf)
    buf.seek(0)
    sess = ort.InferenceSession(buf.read(), providers=["CUDAExecutionProvider", "CPUExecutionProvider"])
    print(f"\nSESSION ACTIVE PROVIDERS: {sess.get_providers()}")
    if "CUDAExecutionProvider" in sess.get_providers():
        print("\nCUDA OK")
        sys.exit(0)
    else:
        print("\nCUDA NOT ACTIVE — fell back to CPU")
        sys.exit(2)
except Exception as e:
    print(f"\nERROR: {type(e).__name__}: {e}")
    sys.exit(3)
