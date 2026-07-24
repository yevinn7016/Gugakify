from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

import librosa
import numpy as np


MAX_DURATION_SECONDS = 30.0
ANALYSIS_SAMPLE_RATE = 22_050
HOP_LENGTH = 512


@dataclass(frozen=True)
class AudioWindow:
    start: float
    duration: float


def _normalize(values: np.ndarray) -> np.ndarray:
    values = np.nan_to_num(values.astype(np.float32), copy=False)
    if not values.size:
        return values
    low, high = np.percentile(values, [5, 95])
    if high <= low + 1e-8:
        return np.zeros_like(values)
    return np.clip((values - low) / (high - low), 0.0, 1.0)


def _band_energy(power: np.ndarray, frequencies: np.ndarray, low: float, high: float) -> np.ndarray:
    mask = (frequencies >= low) & (frequencies < high)
    if not np.any(mask):
        return np.zeros(power.shape[1], dtype=np.float32)
    return np.sqrt(np.mean(power[mask], axis=0)).astype(np.float32)


def _select_window(path: Path, requested_start: float | None) -> AudioWindow:
    total = float(librosa.get_duration(path=str(path)))
    if total <= 0:
        raise ValueError("The audio file has no playable duration.")
    duration = min(MAX_DURATION_SECONDS, total)
    if requested_start is not None:
        start = float(np.clip(requested_start, 0.0, max(0.0, total - duration)))
        return AudioWindow(round(start, 3), round(duration, 3))

    # For long tracks, select the most energetic 30-second window from a cheap mono scan.
    if total > MAX_DURATION_SECONDS + 1:
        preview, sr = librosa.load(path, sr=8_000, mono=True)
        window = int(MAX_DURATION_SECONDS * sr)
        hop = max(sr, window // 10)
        if len(preview) > window:
            starts = range(0, len(preview) - window + 1, hop)
            best = max(starts, key=lambda index: float(np.mean(preview[index:index + window] ** 2)))
            start = min(best / sr, total - duration)
            return AudioWindow(round(start, 3), round(duration, 3))
    return AudioWindow(0.0, round(duration, 3))


def _sections(chroma: np.ndarray, frame_times: np.ndarray, duration: float) -> list[dict[str, float | int]]:
    if chroma.shape[1] < 8 or duration < 8:
        return [{"index": 0, "start": 0.0, "end": round(duration, 3)}]
    section_count = min(3, max(1, int(round(duration / 10))))
    try:
        boundaries = librosa.segment.agglomerative(chroma, k=section_count)
        times = sorted({0.0, duration, *[float(frame_times[min(i, len(frame_times) - 1)]) for i in boundaries]})
    except (ValueError, np.linalg.LinAlgError):
        times = list(np.linspace(0.0, duration, section_count + 1))
    return [
        {"index": index, "start": round(times[index], 3), "end": round(times[index + 1], 3)}
        for index in range(len(times) - 1)
        if times[index + 1] - times[index] >= 0.5
    ]


def analyze_audio(path: Path, start_time: float | None = None) -> dict[str, Any]:
    path = path.resolve()
    if not path.is_file():
        raise FileNotFoundError(path)

    window = _select_window(path, start_time)
    y, sr = librosa.load(
        path,
        sr=ANALYSIS_SAMPLE_RATE,
        mono=True,
        offset=window.start,
        duration=window.duration,
    )
    if not np.any(y):
        raise ValueError("The selected audio segment is silent.")

    onset_raw = librosa.onset.onset_strength(y=y, sr=sr, hop_length=HOP_LENGTH)
    rms_raw = librosa.feature.rms(y=y, hop_length=HOP_LENGTH)[0]
    frame_count = min(len(onset_raw), len(rms_raw))
    onset = _normalize(onset_raw[:frame_count])
    rms = _normalize(rms_raw[:frame_count])
    times = librosa.frames_to_time(np.arange(frame_count), sr=sr, hop_length=HOP_LENGTH)

    stft = np.abs(librosa.stft(y, hop_length=HOP_LENGTH))[:, :frame_count]
    power = stft ** 2
    frequencies = librosa.fft_frequencies(sr=sr)
    low = _normalize(_band_energy(power, frequencies, 20, 250))
    mid = _normalize(_band_energy(power, frequencies, 250, 2_000))
    high = _normalize(_band_energy(power, frequencies, 2_000, sr / 2))

    tempo, beat_frames = librosa.beat.beat_track(onset_envelope=onset_raw, sr=sr, hop_length=HOP_LENGTH)
    bpm = float(np.asarray(tempo).reshape(-1)[0]) if np.size(tempo) else 0.0
    beat_times = librosa.frames_to_time(beat_frames, sr=sr, hop_length=HOP_LENGTH)
    onset_frames = librosa.onset.onset_detect(
        onset_envelope=onset_raw,
        sr=sr,
        hop_length=HOP_LENGTH,
        units="frames",
        backtrack=False,
    )
    events = []
    last_time = -1.0
    for frame in onset_frames:
        if frame >= frame_count:
            continue
        event_time = float(times[frame])
        strength = float(onset[frame])
        if strength < 0.48 or event_time - last_time < 0.18:
            continue
        events.append({"time": round(event_time, 3), "strength": round(strength, 4)})
        last_time = event_time

    chroma = librosa.feature.chroma_cqt(y=y, sr=sr, hop_length=HOP_LENGTH)[:, :frame_count]
    sample_step = max(1, int(round(0.1 * sr / HOP_LENGTH)))
    samples = [
        {
            "time": round(float(times[i]), 3),
            "onset": round(float(onset[i]), 4),
            "energy": round(float(rms[i]), 4),
            "lowBand": round(float(low[i]), 4),
            "midBand": round(float(mid[i]), 4),
            "highBand": round(float(high[i]), 4),
        }
        for i in range(0, frame_count, sample_step)
    ]
    return {
        "sourceStart": window.start,
        "duration": window.duration,
        "sampleRate": sr,
        "bpm": round(bpm, 2),
        "beats": [round(float(value), 3) for value in beat_times if value <= window.duration],
        "onsets": events,
        "sections": _sections(chroma, times, window.duration),
        "samples": samples,
        "summary": {
            "energy": round(float(np.mean(rms)), 4),
            "lowBand": round(float(np.mean(low)), 4),
            "midBand": round(float(np.mean(mid)), 4),
            "highBand": round(float(np.mean(high)), 4),
        },
    }
