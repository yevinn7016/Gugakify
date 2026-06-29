from pathlib import Path

import numpy as np

from app.models.base import FrameTransformContext, ImageGenerationContext


class DcGanImageGeneratorAdapter:
    """Adapter for AI Hub DCGAN ink painting image generation models."""

    name = "aihub-dcgan-image-generator"

    def __init__(self, checkpoint_path: Path | None = None) -> None:
        self.checkpoint_path = checkpoint_path

    def transform_frame(
        self,
        frame: np.ndarray,
        context: FrameTransformContext,
    ) -> np.ndarray:
        # DCGAN generates new ink painting images from latent vectors. It is not
        # a direct frame-to-frame converter, so it should not drive MV conversion.
        return frame

    def generate_reference_image(
        self,
        context: ImageGenerationContext,
        width: int,
        height: int,
    ) -> np.ndarray:
        if self.checkpoint_path is None:
            return self._preview_reference(width, height, context.seed)

        # TODO: Load the AI Hub DCGAN checkpoint and sample a style reference.
        return self._preview_reference(width, height, context.seed)

    def _preview_reference(self, width: int, height: int, seed: int | None) -> np.ndarray:
        rng = np.random.default_rng(seed)
        base = rng.normal(loc=214, scale=18, size=(height, width, 3))
        base[:, :, 0] *= 0.92
        base[:, :, 1] *= 0.96
        base[:, :, 2] *= 1.02
        return np.clip(base, 0, 255).astype(np.uint8)
