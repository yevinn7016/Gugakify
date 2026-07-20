from __future__ import annotations

from pathlib import Path
from typing import Iterable, Tuple

from instrument_profiles import get_instrument_profile
from midi_processor import (
    choose_best_octave_shift as _choose_best_octave_shift,
    fold_pitch_into_range,
    process_midi,
)


def choose_best_octave_shift(
    pitches: Iterable[int], min_pitch: int, max_pitch: int
) -> int:
    """기존 호출부를 위한 호환 함수."""
    return _choose_best_octave_shift(pitches, min_pitch, max_pitch)


def fit_midi_to_instrument_range(
    input_midi: Path,
    output_midi: Path,
    instrument: str,
) -> Path:
    return process_midi(input_midi, output_midi, instrument)


def fit_midi_to_danso_range(input_midi: Path, output_midi: Path) -> Path:
    """기존 단소 전용 호출부를 유지한다."""
    return fit_midi_to_instrument_range(input_midi, output_midi, "danso")


DANSO_MIN_PITCH = get_instrument_profile("danso").min_pitch
DANSO_MAX_PITCH = get_instrument_profile("danso").max_pitch


if __name__ == "__main__":
    project_root = Path(__file__).resolve().parents[1]
    fit_midi_to_danso_range(
        input_midi=project_root / "outputs" / "basic_pitch" / "vocals_basic_pitch.mid",
        output_midi=project_root / "outputs" / "danso" / "vocals_danso.mid",
    )

