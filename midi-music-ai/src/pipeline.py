from __future__ import annotations

import argparse
import json
import shutil
import uuid
from pathlib import Path
from typing import Any, Dict, Optional

from instrument_profiles import get_instrument_profile
from job_manager import read_status, write_status
from midi_processor import process_midi
from mixer import mix_audio
from render_danso import ReaperRenderError, render_midi_with_reaper
from separator import separate_audio
from transcriber import transcribe_audio


def prepare_render_job(
    input_audio: Path,
    vocal_instrument: str,
    accompaniment_instrument: str,
    output_root: Path,
    job_id: Optional[str] = None,
    resume_queued_job: bool = False,
) -> Dict[str, Any]:
    get_instrument_profile(vocal_instrument)
    get_instrument_profile(accompaniment_instrument)

    input_audio = input_audio.resolve()
    if not input_audio.exists():
        raise FileNotFoundError(f"업로드 음원이 없습니다: {input_audio}")
    if not input_audio.is_file():
        raise ValueError(f"입력 경로가 파일이 아닙니다: {input_audio}")

    job_id = job_id or str(uuid.uuid4())
    job_dir = output_root.resolve() / "jobs" / job_id
    if job_dir.exists():
        if not resume_queued_job:
            raise FileExistsError(f"이미 존재하는 작업 ID입니다: {job_id}")
        queued_status = read_status(job_dir)
        if queued_status.get("status") != "queued":
            raise RuntimeError(
                f"대기 상태가 아닌 기존 작업입니다: {queued_status.get('status')}"
            )
    else:
        job_dir.mkdir(parents=True)
    source_dir = job_dir / "source"
    source_dir.mkdir()
    source_audio = source_dir / input_audio.name
    shutil.copy2(input_audio, source_audio)

    common = {
        "input_audio": str(source_audio),
        "vocal_instrument": vocal_instrument,
        "accompaniment_instrument": accompaniment_instrument,
    }

    try:
        write_status(job_dir, "separating", **common)
        stems = separate_audio(source_audio, job_dir / "stems")

        write_status(job_dir, "transcribing", **common)
        raw_vocal_midi = transcribe_audio(
            stems["vocal"], job_dir / "raw_midi" / "vocal.mid"
        )
        raw_other_midi = transcribe_audio(
            stems["other"], job_dir / "raw_midi" / "other.mid"
        )

        write_status(job_dir, "processing_midi", **common)
        vocal_midi = process_midi(
            raw_vocal_midi,
            job_dir
            / "processed_midi"
            / f"vocal_{vocal_instrument}.mid",
            vocal_instrument,
        )
        accompaniment_midi = process_midi(
            raw_other_midi,
            job_dir
            / "processed_midi"
            / f"other_{accompaniment_instrument}.mid",
            accompaniment_instrument,
        )

        return write_status(
            job_dir,
            "waiting_for_manual_render",
            **common,
            midi_files={
                "vocal": str(vocal_midi),
                "accompaniment": str(accompaniment_midi),
            },
            required_result_file=str(job_dir / "result.wav"),
            automatic_render_files={
                "vocal": str(
                    job_dir / "rendered" / f"vocal_{vocal_instrument}.wav"
                ),
                "accompaniment": str(
                    job_dir
                    / "rendered"
                    / f"other_{accompaniment_instrument}.wav"
                ),
            },
        )
    except Exception as exc:
        write_status(
            job_dir,
            "failed",
            **common,
            error_type=type(exc).__name__,
            error=str(exc),
        )
        raise


def attempt_automatic_render(
    job_dir: Path,
    render_config_path: Path,
) -> Dict[str, Any]:
    status = read_status(job_dir)
    if status["status"] != "waiting_for_manual_render":
        raise RuntimeError("자동 렌더링을 시도할 수 있는 작업 상태가 아닙니다.")

    config = json.loads(render_config_path.read_text(encoding="utf-8"))
    rendered_paths: Dict[str, str] = {}
    try:
        for part, instrument_field in (
            ("vocal", "vocal_instrument"),
            ("accompaniment", "accompaniment_instrument"),
        ):
            instrument = status[instrument_field]
            instrument_config = config["instruments"][instrument]
            output_wav = Path(status["automatic_render_files"][part])
            rendered = render_midi_with_reaper(
                input_midi=Path(status["midi_files"][part]),
                template_project=Path(instrument_config["template_project"]),
                runtime_midi=Path(instrument_config["runtime_midi"]),
                output_wav=output_wav,
                reaper_executable=(
                    Path(config["reaper_executable"])
                    if config.get("reaper_executable")
                    else None
                ),
            )
            rendered_paths[part] = str(rendered)
    except (KeyError, FileNotFoundError, ReaperRenderError, TimeoutError) as exc:
        return write_status(
            job_dir,
            "waiting_for_manual_render",
            auto_render_error=str(exc),
            auto_render_error_type=type(exc).__name__,
        )

    return complete_render_job(job_dir)


def complete_render_job(
    job_dir: Path,
    vocal_wav: Optional[Path] = None,
    accompaniment_wav: Optional[Path] = None,
) -> Dict[str, Any]:
    job_dir = job_dir.resolve()
    status = read_status(job_dir)
    if status["status"] not in {
        "waiting_for_manual_render",
        "mixing",
    }:
        raise RuntimeError(f"합성을 시작할 수 없는 상태입니다: {status['status']}")

    expected_vocal = Path(status["automatic_render_files"]["vocal"])
    expected_accompaniment = Path(
        status["automatic_render_files"]["accompaniment"]
    )
    expected_vocal.parent.mkdir(parents=True, exist_ok=True)

    if vocal_wav and vocal_wav.resolve() != expected_vocal.resolve():
        shutil.copy2(vocal_wav.resolve(), expected_vocal)
    if (
        accompaniment_wav
        and accompaniment_wav.resolve() != expected_accompaniment.resolve()
    ):
        shutil.copy2(accompaniment_wav.resolve(), expected_accompaniment)

    if not expected_vocal.exists() or not expected_accompaniment.exists():
        raise FileNotFoundError(
            "수동 렌더링 WAV 두 개가 모두 필요합니다: "
            f"{expected_vocal}, {expected_accompaniment}"
        )

    write_status(job_dir, "mixing")
    try:
        result_wav = mix_audio(
            expected_vocal,
            expected_accompaniment,
            job_dir / "result.wav",
        )
    except Exception as exc:
        write_status(
            job_dir,
            "mix_failed",
            error_type=type(exc).__name__,
            error=str(exc),
        )
        raise
    return write_status(job_dir, "completed", result_wav=str(result_wav))


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="국악 음원 편곡 파이프라인")
    subparsers = parser.add_subparsers(dest="command", required=True)

    prepare = subparsers.add_parser("prepare", help="MIDI 생성까지 자동 처리")
    prepare.add_argument("input_audio", type=Path)
    prepare.add_argument("--vocal-instrument", required=True)
    prepare.add_argument("--accompaniment-instrument", required=True)
    prepare.add_argument("--job-id")

    complete = subparsers.add_parser("complete", help="수동 렌더 WAV 합성")
    complete.add_argument("job_id")
    complete.add_argument("--vocal-wav", type=Path)
    complete.add_argument("--accompaniment-wav", type=Path)

    auto_render = subparsers.add_parser(
        "auto-render", help="REAPER 자동 렌더링 시도"
    )
    auto_render.add_argument("job_id")
    auto_render.add_argument("render_config", type=Path)
    return parser


def main() -> None:
    args = build_parser().parse_args()
    project_root = Path(__file__).resolve().parents[1]
    output_root = project_root / "outputs"

    if args.command == "prepare":
        result = prepare_render_job(
            input_audio=args.input_audio,
            vocal_instrument=args.vocal_instrument,
            accompaniment_instrument=args.accompaniment_instrument,
            output_root=output_root,
            job_id=args.job_id,
        )
    elif args.command == "complete":
        result = complete_render_job(
            output_root / "jobs" / args.job_id,
            vocal_wav=args.vocal_wav,
            accompaniment_wav=args.accompaniment_wav,
        )
    else:
        result = attempt_automatic_render(
            output_root / "jobs" / args.job_id,
            args.render_config,
        )

    print(json.dumps(result, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
