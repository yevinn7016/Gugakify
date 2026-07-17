from __future__ import annotations

from pathlib import Path

from basic_pitch import ICASSP_2022_MODEL_PATH
from basic_pitch.inference import predict_and_save


def transcribe_audio(audio_path: Path, output_midi: Path) -> Path:
    audio_path = audio_path.resolve()
    output_midi = output_midi.resolve()

    if not audio_path.exists():
        raise FileNotFoundError(f"채보할 음원이 없습니다: {audio_path}")

    # 작업별 전용 폴더를 사용하므로 이전 실행 결과를 잘못 선택하지 않는다.
    generated_dir = output_midi.parent / f".{output_midi.stem}_basic_pitch"
    generated_dir.mkdir(parents=True, exist_ok=True)

    predict_and_save(
        audio_path_list=[str(audio_path)],
        output_directory=str(generated_dir),
        save_midi=True,
        sonify_midi=False,
        save_model_outputs=False,
        save_notes=True,
        model_or_model_path=ICASSP_2022_MODEL_PATH,
    )

    generated_midis = sorted(
        generated_dir.glob("*.mid"),
        key=lambda path: path.stat().st_mtime,
        reverse=True,
    )
    if not generated_midis:
        raise RuntimeError(f"BasicPitch가 MIDI를 생성하지 못했습니다: {audio_path}")

    output_midi.parent.mkdir(parents=True, exist_ok=True)
    generated_midis[0].replace(output_midi)
    return output_midi

