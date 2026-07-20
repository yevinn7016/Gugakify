from __future__ import annotations

from pathlib import Path

from midi_processor import process_midi
from transcriber import transcribe_audio


def create_midi_from_vocal(vocal_path: Path, output_dir: Path) -> Path:
    """기존 단소 파이프라인 API를 유지한다."""
    return transcribe_audio(
        audio_path=vocal_path,
        output_midi=output_dir / f"{vocal_path.stem}_basic_pitch.mid",
    )


def run_pipeline(
    vocal_path: Path,
    output_root: Path,
    instrument: str = "danso",
) -> Path:
    print("[1/2] BasicPitch 자동 채보 시작")
    original_midi = create_midi_from_vocal(
        vocal_path=vocal_path,
        output_dir=output_root / "basic_pitch",
    )

    print(f"[2/2] {instrument} MIDI 정제 시작")
    processed_midi = output_root / instrument / f"{vocal_path.stem}_{instrument}.mid"
    process_midi(
        input_midi=original_midi,
        output_midi=processed_midi,
        instrument=instrument,
    )

    print(f"악기용 MIDI 생성 완료: {processed_midi}")
    return processed_midi


if __name__ == "__main__":
    project_root = Path(__file__).resolve().parents[1]
    run_pipeline(
        vocal_path=project_root / "uploads" / "vocals.wav",
        output_root=project_root / "outputs",
    )

