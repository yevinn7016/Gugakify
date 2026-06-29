from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class VideoMetadata:
    path: Path
    fps: float
    width: int
    height: int
    frame_count: int
    duration: float


def probe_video(video_path: Path) -> VideoMetadata:
    try:
        import cv2
    except ImportError as exc:
        raise RuntimeError("opencv-python-headless is required to probe videos.") from exc

    capture = cv2.VideoCapture(str(video_path))
    if not capture.isOpened():
        raise ValueError(f"Could not open video: {video_path}")

    fps = capture.get(cv2.CAP_PROP_FPS) or 0.0
    frame_count = int(capture.get(cv2.CAP_PROP_FRAME_COUNT) or 0)
    width = int(capture.get(cv2.CAP_PROP_FRAME_WIDTH) or 0)
    height = int(capture.get(cv2.CAP_PROP_FRAME_HEIGHT) or 0)
    capture.release()

    duration = frame_count / fps if fps > 0 else 0.0
    return VideoMetadata(
        path=video_path,
        fps=fps,
        width=width,
        height=height,
        frame_count=frame_count,
        duration=duration,
    )
