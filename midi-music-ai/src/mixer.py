from __future__ import annotations

from pathlib import Path

import numpy as np
import soundfile as sf


def _as_stereo(audio: np.ndarray) -> np.ndarray:
    if audio.ndim == 1:
        return np.column_stack((audio, audio))
    if audio.shape[1] == 1:
        return np.repeat(audio, 2, axis=1)
    return audio[:, :2]


def mix_audio(
    vocal_path: Path,
    accompaniment_path: Path,
    output_path: Path,
    vocal_gain: float = 0.8,
    accompaniment_gain: float = 0.7,
) -> Path:
    if not vocal_path.exists() or not accompaniment_path.exists():
        raise FileNotFoundError("합성할 보컬 또는 반주 WAV가 없습니다.")

    vocal, vocal_sr = sf.read(vocal_path, always_2d=False)
    accompaniment, accompaniment_sr = sf.read(
        accompaniment_path, always_2d=False
    )
    if vocal_sr != accompaniment_sr:
        raise ValueError(
            f"렌더 WAV의 샘플레이트가 다릅니다: {vocal_sr}, {accompaniment_sr}"
        )

    vocal = _as_stereo(vocal)
    accompaniment = _as_stereo(accompaniment)
    length = max(len(vocal), len(accompaniment))
    vocal = np.pad(vocal, ((0, length - len(vocal)), (0, 0)))
    accompaniment = np.pad(
        accompaniment,
        ((0, length - len(accompaniment)), (0, 0)),
    )

    mixed = vocal * vocal_gain + accompaniment * accompaniment_gain
    peak = float(np.max(np.abs(mixed))) if mixed.size else 0.0
    if peak > 0.99:
        mixed *= 0.99 / peak

    output_path.parent.mkdir(parents=True, exist_ok=True)
    sf.write(output_path, mixed, vocal_sr, subtype="PCM_16")
    return output_path

