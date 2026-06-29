from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class Shot:
    index: int
    start_frame: int
    end_frame: int
    keyframe: int


def detect_shots(
    frame_paths: list[Path],
    threshold: float = 0.55,
    min_shot_frames: int = 12,
) -> list[Shot]:
    if not frame_paths:
        return []

    try:
        import cv2
    except ImportError as exc:
        raise RuntimeError("opencv-python-headless is required for shot detection.") from exc

    boundaries = [0]
    previous_hist = None

    for index, frame_path in enumerate(frame_paths):
        frame = cv2.imread(str(frame_path))
        if frame is None:
            continue

        hsv = cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)
        hist = cv2.calcHist([hsv], [0, 1], None, [32, 32], [0, 180, 0, 256])
        cv2.normalize(hist, hist)

        if previous_hist is not None:
            diff = 1.0 - cv2.compareHist(previous_hist, hist, cv2.HISTCMP_CORREL)
            enough_distance = index - boundaries[-1] >= min_shot_frames
            if diff >= threshold and enough_distance:
                boundaries.append(index)

        previous_hist = hist

    shots: list[Shot] = []
    for shot_index, start in enumerate(boundaries):
        end = (boundaries[shot_index + 1] - 1) if shot_index + 1 < len(boundaries) else len(frame_paths) - 1
        keyframe = start + ((end - start) // 2)
        shots.append(Shot(index=shot_index, start_frame=start, end_frame=end, keyframe=keyframe))

    return shots
