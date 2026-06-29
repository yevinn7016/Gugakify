from dataclasses import dataclass
from pathlib import Path
import shutil

import numpy as np

from app.models.base import FrameTransformContext, ModelAdapter
from app.video.io import extract_audio, extract_frames, merge_audio, write_video_from_frames
from app.video.metadata import VideoMetadata, probe_video
from app.video.shots import Shot, detect_shots


@dataclass(frozen=True)
class PipelineResult:
    output_video_path: Path
    thumbnail_path: Path | None
    metadata: VideoMetadata
    output_file_size: int
    shot_count: int


class VideoConversionPipeline:
    def __init__(self, model_adapter: ModelAdapter) -> None:
        self.model_adapter = model_adapter

    def run(
        self,
        job_id: str,
        input_video_path: Path,
        work_dir: Path,
        output_dir: Path,
        style_type: str,
        preserve_audio: bool,
    ) -> PipelineResult:
        metadata = probe_video(input_video_path)
        frames_dir = work_dir / job_id / "frames"
        styled_dir = work_dir / job_id / "styled_frames"
        audio_path = work_dir / job_id / "audio.aac"

        frame_paths = extract_frames(input_video_path, frames_dir)
        shots = detect_shots(frame_paths)
        audio = extract_audio(input_video_path, audio_path) if preserve_audio else None

        styled_paths = self._style_frames(
            job_id=job_id,
            frame_paths=frame_paths,
            shots=shots,
            styled_dir=styled_dir,
            style_type=style_type,
        )

        silent_video = output_dir / f"{job_id}_silent.mp4"
        merged_video = output_dir / f"{job_id}_output.mp4"
        write_video_from_frames(styled_paths, silent_video, metadata)
        final_video = merge_audio(silent_video, audio, merged_video)

        thumbnail_path = None
        if styled_paths:
            thumbnail_path = output_dir / f"{job_id}_thumbnail.png"
            shutil.copyfile(styled_paths[0], thumbnail_path)

        return PipelineResult(
            output_video_path=final_video,
            thumbnail_path=thumbnail_path,
            metadata=metadata,
            output_file_size=final_video.stat().st_size if final_video.exists() else 0,
            shot_count=len(shots),
        )

    def _style_frames(
        self,
        job_id: str,
        frame_paths: list[Path],
        shots: list[Shot],
        styled_dir: Path,
        style_type: str,
    ) -> list[Path]:
        try:
            import cv2
        except ImportError as exc:
            raise RuntimeError("opencv-python-headless is required for style frame output.") from exc

        styled_dir.mkdir(parents=True, exist_ok=True)
        styled_paths: list[Path] = []
        shot_by_frame = _index_shots(shots)
        previous_keyframe_path: Path | None = None
        previous_styled_keyframe_path: Path | None = None

        for frame_index, frame_path in enumerate(frame_paths):
            shot = shot_by_frame.get(frame_index, shots[-1] if shots else None)
            is_keyframe = shot is None or frame_index == shot.keyframe
            frame = cv2.imread(str(frame_path))
            if frame is None:
                raise ValueError(f"Could not read frame: {frame_path}")

            context = FrameTransformContext(
                job_id=job_id,
                style_type=style_type,
                shot_index=shot.index if shot else 0,
                frame_index=frame_index,
                is_keyframe=is_keyframe,
                previous_keyframe_path=previous_keyframe_path,
                previous_styled_keyframe_path=previous_styled_keyframe_path,
            )
            styled = self.model_adapter.transform_frame(frame, context)
            styled = _match_resolution(styled, frame)

            output_path = styled_dir / frame_path.name
            cv2.imwrite(str(output_path), styled)
            styled_paths.append(output_path)

            if is_keyframe:
                previous_keyframe_path = frame_path
                previous_styled_keyframe_path = output_path

        return styled_paths


def _index_shots(shots: list[Shot]) -> dict[int, Shot]:
    by_frame: dict[int, Shot] = {}
    for shot in shots:
        for frame_index in range(shot.start_frame, shot.end_frame + 1):
            by_frame[frame_index] = shot
    return by_frame


def _match_resolution(styled: np.ndarray, original: np.ndarray) -> np.ndarray:
    if styled.shape[:2] == original.shape[:2]:
        return styled

    import cv2

    height, width = original.shape[:2]
    return cv2.resize(styled, (width, height), interpolation=cv2.INTER_AREA)
