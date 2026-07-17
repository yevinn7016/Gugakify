from __future__ import annotations

import shutil
import subprocess
import time
from pathlib import Path
from typing import Optional


class ReaperRenderError(RuntimeError):
    """REAPER 렌더링 실패 예외."""


def find_reaper_executable() -> Path:
    """
    일반적인 Windows 설치 경로에서 REAPER 실행 파일을 찾는다.
    """
    candidates = [
        Path(r"C:\Program Files\REAPER (x64)\reaper.exe"),
        Path(r"C:\Program Files\REAPER\reaper.exe"),
        Path(r"C:\Program Files (x86)\REAPER\reaper.exe"),
    ]

    for candidate in candidates:
        if candidate.exists():
            return candidate

    raise FileNotFoundError(
        "REAPER 실행 파일을 찾지 못했습니다.\n"
        "render_danso.py의 REAPER 경로를 직접 지정해 주세요."
    )


def wait_for_stable_file(
    file_path: Path,
    timeout_seconds: float = 180.0,
    check_interval: float = 0.5,
) -> None:
    """
    출력 파일이 생성되고 크기가 안정될 때까지 기다린다.
    """
    started_at = time.monotonic()
    previous_size = -1
    stable_checks = 0

    while time.monotonic() - started_at < timeout_seconds:
        if file_path.exists():
            current_size = file_path.stat().st_size

            if current_size > 0 and current_size == previous_size:
                stable_checks += 1
            else:
                stable_checks = 0

            previous_size = current_size

            if stable_checks >= 3:
                return

        time.sleep(check_interval)

    raise TimeoutError(
        f"출력 WAV가 제한 시간 내에 완성되지 않았습니다: {file_path}"
    )


def render_midi_with_reaper(
    input_midi: Path,
    template_project: Path,
    runtime_midi: Path,
    output_wav: Path,
    reaper_executable: Optional[Path] = None,
    timeout_seconds: int = 300,
) -> Path:
    """
    단소용 MIDI를 REAPER + Kontakt + DanSo LE로 WAV 렌더링한다.

    동작 방식:
    1. 입력 MIDI를 템플릿이 참조하는 고정 MIDI 경로로 복사
    2. 기존 출력 WAV 삭제
    3. REAPER -renderproject 명령 실행
    4. 출력 WAV 생성 여부 검사
    """
    input_midi = input_midi.resolve()
    template_project = template_project.resolve()
    runtime_midi = runtime_midi.resolve()
    output_wav = output_wav.resolve()

    if not input_midi.exists():
        raise FileNotFoundError(f"입력 MIDI가 없습니다: {input_midi}")

    if not template_project.exists():
        raise FileNotFoundError(
            f"REAPER 템플릿이 없습니다: {template_project}"
        )

    if reaper_executable is None:
        reaper_executable = find_reaper_executable()
    else:
        reaper_executable = reaper_executable.resolve()

    if not reaper_executable.exists():
        raise FileNotFoundError(
            f"REAPER 실행 파일이 없습니다: {reaper_executable}"
        )

    runtime_midi.parent.mkdir(parents=True, exist_ok=True)
    output_wav.parent.mkdir(parents=True, exist_ok=True)

    # REAPER 템플릿이 참조하는 MIDI 파일을 최신 파일로 교체
    shutil.copy2(input_midi, runtime_midi)

    if not runtime_midi.exists() or runtime_midi.stat().st_size == 0:
        raise ReaperRenderError(
            f"런타임 MIDI 복사에 실패했습니다: {runtime_midi}"
        )

    # 덮어쓰기 확인창 방지
    if output_wav.exists():
        output_wav.unlink()

    command = [
        str(reaper_executable),
        "-renderproject",
        str(template_project),
    ]

    print("=" * 60)
    print("REAPER 자동 렌더링 시작")
    print(f"입력 MIDI  : {input_midi}")
    print(f"런타임 MIDI: {runtime_midi}")
    print(f"템플릿     : {template_project}")
    print(f"출력 WAV   : {output_wav}")
    print("=" * 60)

    try:
        completed = subprocess.run(
            command,
            check=False,
            timeout=timeout_seconds,
        )
    except subprocess.TimeoutExpired as exc:
        raise ReaperRenderError(
            f"REAPER 렌더링 제한 시간({timeout_seconds}초)을 초과했습니다."
        ) from exc

    # REAPER/Kontakt가 렌더 완료 후 종료 과정에서
    # 비정상 종료 코드를 반환하는 경우가 있으므로,
    # 출력 WAV의 정상 생성 여부를 우선 검사한다.
    try:
        wait_for_stable_file(
            file_path=output_wav,
            timeout_seconds=30,
        )
    except TimeoutError as exc:
        raise ReaperRenderError(
            "REAPER가 종료되었고 최종 WAV도 생성되지 않았습니다. "
            f"returncode={completed.returncode}"
        ) from exc

    if not output_wav.exists():
        raise ReaperRenderError(
            "최종 WAV가 생성되지 않았습니다. "
            f"returncode={completed.returncode}"
        )

    if output_wav.stat().st_size < 1_000:
        raise ReaperRenderError(
            "WAV 파일은 생성되었지만 크기가 지나치게 작습니다. "
            "무음 또는 렌더 실패 가능성이 있습니다."
        )

    if completed.returncode != 0:
        print(
            "[경고] REAPER가 렌더 후 비정상 종료 코드를 반환했습니다. "
            f"returncode={completed.returncode}"
        )
        print(
            "[경고] 그러나 출력 WAV가 정상 생성되어 "
            "렌더링 성공으로 처리합니다."
        )

    print("REAPER 자동 렌더링 완료")
    print(f"생성 파일: {output_wav}")
    print(f"파일 크기: {output_wav.stat().st_size:,} bytes")

    return output_wav


def main() -> None:
    project_root = Path(__file__).resolve().parents[1]

    input_midi = (
        project_root
        / "outputs"
        / "danso"
        / "vocals_danso.mid"
    )

    template_project = (
        project_root
        / "templates"
        / "danso_template.rpp"
    )

    runtime_midi = (
        project_root
        / "runtime"
        / "current_danso.mid"
    )

    output_wav = (
        project_root
        / "outputs"
        / "danso_wav"
        / "vocals_danso.wav"
    )

    render_midi_with_reaper(
        input_midi=input_midi,
        template_project=template_project,
        runtime_midi=runtime_midi,
        output_wav=output_wav,
    )


if __name__ == "__main__":
    main()
