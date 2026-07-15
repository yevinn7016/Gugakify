from dataclasses import dataclass
from pathlib import Path
from typing import Protocol

import numpy as np


@dataclass(frozen=True)
class FrameTransformContext:
    job_id: str
    style_type: str
    shot_index: int
    frame_index: int
    is_keyframe: bool
    previous_keyframe_path: Path | None = None
    previous_styled_keyframe_path: Path | None = None
    previous_styled_frame_path: Path | None = None


@dataclass(frozen=True)
class ImageGenerationContext:
    job_id: str
    style_type: str
    seed: int | None = None


class ModelAdapter(Protocol):
    name: str

    def transform_frame(
        self,
        frame: np.ndarray,
        context: FrameTransformContext,
    ) -> np.ndarray:
        ...
