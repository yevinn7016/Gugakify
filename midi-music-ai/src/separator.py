from __future__ import annotations

import shutil
import subprocess
import sys
from pathlib import Path
from typing import Dict


def separate_audio(input_audio: Path, stems_dir: Path) -> Dict[str, Path]:
    input_audio = input_audio.resolve()
    stems_dir = stems_dir.resolve()

    if not input_audio.exists():
        raise FileNotFoundError(f"업로드 음원이 없습니다: {input_audio}")

    demucs_root = stems_dir / "demucs"
    command = [
        sys.executable,
        "-m",
        "demucs",
        "--two-stems=vocals",
        "-o",
        str(demucs_root),
        str(input_audio),
    ]
    subprocess.run(command, check=True)

    result_dir = demucs_root / "htdemucs" / input_audio.stem
    source_vocals = result_dir / "vocals.wav"
    source_other = result_dir / "no_vocals.wav"

    if not source_vocals.exists() or not source_other.exists():
        raise RuntimeError(
            "Demucs 결과에서 vocals.wav 또는 no_vocals.wav를 찾지 못했습니다."
        )

    stems_dir.mkdir(parents=True, exist_ok=True)
    vocals = stems_dir / "vocals.wav"
    other = stems_dir / "other.wav"
    shutil.copy2(source_vocals, vocals)
    shutil.copy2(source_other, other)

    return {"vocal": vocals, "other": other}

