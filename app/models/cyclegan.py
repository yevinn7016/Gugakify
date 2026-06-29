from pathlib import Path

import numpy as np

from app.models.base import FrameTransformContext


class CycleGanStyleTransferAdapter:
    """Adapter for AI Hub ink painting style transfer CycleGAN models."""

    name = "aihub-cyclegan-style-transfer"

    def __init__(self, checkpoint_path: Path | None = None) -> None:
        self.checkpoint_path = checkpoint_path

    def transform_frame(
        self,
        frame: np.ndarray,
        context: FrameTransformContext,
    ) -> np.ndarray:
        if self.checkpoint_path is None:
            return self._preview_ink_style(frame)

        # TODO: Load the AI Hub CycleGAN checkpoint and run image-to-image inference.
        # Keep this method deterministic per shot to reduce temporal flicker.
        return self._preview_ink_style(frame)

    def _preview_ink_style(self, frame: np.ndarray) -> np.ndarray:
        try:
            import cv2
        except ImportError as exc:
            raise RuntimeError("opencv-python-headless is required for preview transforms.") from exc

        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        smooth = cv2.bilateralFilter(gray, d=9, sigmaColor=60, sigmaSpace=60)
        edges = cv2.Canny(smooth, threshold1=60, threshold2=140)
        paper = cv2.cvtColor(smooth, cv2.COLOR_GRAY2BGR)
        paper = cv2.normalize(paper, None, alpha=50, beta=235, norm_type=cv2.NORM_MINMAX)
        paper[:, :, 1] = np.clip(paper[:, :, 1] * 0.96 + 8, 0, 255)
        paper[:, :, 2] = np.clip(paper[:, :, 2] * 0.90 + 18, 0, 255)
        ink = 255 - cv2.cvtColor(edges, cv2.COLOR_GRAY2BGR)
        return cv2.multiply(paper, ink, scale=1 / 255.0).astype(np.uint8)
