import shutil
import subprocess
from pathlib import Path

from app.video.metadata import VideoMetadata


def extract_frames(video_path: Path, output_dir: Path) -> list[Path]:
    try:
        import cv2
    except ImportError as exc:
        raise RuntimeError("opencv-python-headless is required to extract frames.") from exc

    output_dir.mkdir(parents=True, exist_ok=True)
    capture = cv2.VideoCapture(str(video_path))
    if not capture.isOpened():
        raise ValueError(f"Could not open video: {video_path}")

    frame_paths: list[Path] = []
    index = 0
    while True:
        ok, frame = capture.read()
        if not ok:
            break

        frame_path = output_dir / f"frame_{index:06d}.png"
        cv2.imwrite(str(frame_path), frame)
        frame_paths.append(frame_path)
        index += 1

    capture.release()
    return frame_paths


def write_video_from_frames(
    frame_paths: list[Path],
    output_path: Path,
    metadata: VideoMetadata,
) -> Path:
    try:
        import cv2
    except ImportError as exc:
        raise RuntimeError("opencv-python-headless is required to write videos.") from exc

    if not frame_paths:
        raise ValueError("No frames to write.")

    output_path.parent.mkdir(parents=True, exist_ok=True)
    fourcc = cv2.VideoWriter_fourcc(*"mp4v")
    writer = cv2.VideoWriter(
        str(output_path),
        fourcc,
        metadata.fps or 24.0,
        (metadata.width, metadata.height),
    )

    for frame_path in frame_paths:
        frame = cv2.imread(str(frame_path))
        if frame is None:
            raise ValueError(f"Could not read frame: {frame_path}")
        writer.write(frame)

    writer.release()
    return output_path


def extract_audio(video_path: Path, output_path: Path) -> Path | None:
    if shutil.which("ffmpeg") is None:
        return None

    output_path.parent.mkdir(parents=True, exist_ok=True)
    command = [
        "ffmpeg",
        "-y",
        "-i",
        str(video_path),
        "-vn",
        "-acodec",
        "copy",
        str(output_path),
    ]
    result = subprocess.run(command, capture_output=True, text=True, check=False)
    return output_path if result.returncode == 0 and output_path.exists() else None


def merge_audio(video_path: Path, audio_path: Path | None, output_path: Path) -> Path:
    if shutil.which("ffmpeg") is None:
        return video_path

    output_path.parent.mkdir(parents=True, exist_ok=True)
    if audio_path is None:
        return transcode_video_for_web(video_path, output_path)

    command = [
        "ffmpeg",
        "-y",
        "-i",
        str(video_path),
        "-i",
        str(audio_path),
        "-c:v",
        "libx264",
        "-preset",
        "veryfast",
        "-crf",
        "23",
        "-pix_fmt",
        "yuv420p",
        "-c:a",
        "aac",
        "-movflags",
        "+faststart",
        "-shortest",
        str(output_path),
    ]
    result = subprocess.run(command, capture_output=True, text=True, check=False)
    return output_path if result.returncode == 0 and output_path.exists() else video_path


def transcode_video_for_web(video_path: Path, output_path: Path) -> Path:
    command = [
        "ffmpeg",
        "-y",
        "-i",
        str(video_path),
        "-c:v",
        "libx264",
        "-preset",
        "veryfast",
        "-crf",
        "23",
        "-pix_fmt",
        "yuv420p",
        "-movflags",
        "+faststart",
        "-an",
        str(output_path),
    ]
    result = subprocess.run(command, capture_output=True, text=True, check=False)
    return output_path if result.returncode == 0 and output_path.exists() else video_path
