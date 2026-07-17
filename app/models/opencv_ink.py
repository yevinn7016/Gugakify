import os

import numpy as np

from app.models.base import FrameTransformContext


class OpenCVInkWashAdapter:
    """Deterministic OpenCV ink-wash style adapter for every video frame."""

    name = "opencv-ink-wash"

    def __init__(self) -> None:
        self.ink_strength = float(os.getenv("OPENCV_INK_STRENGTH", "0.92"))
        self.wash_strength = float(os.getenv("OPENCV_WASH_STRENGTH", "0.86"))
        self.paper_strength = float(os.getenv("OPENCV_PAPER_STRENGTH", "0.18"))
        self.white_space = float(os.getenv("OPENCV_WHITE_SPACE", "0.26"))
        self.detail_levels = int(os.getenv("OPENCV_DETAIL_LEVELS", "8"))
        self.texture_strength = float(os.getenv("OPENCV_TEXTURE_STRENGTH", "0.22"))
        self.detail_preserve = float(os.getenv("OPENCV_DETAIL_PRESERVE", "0.20"))
        self.fine_line_strength = float(os.getenv("OPENCV_FINE_LINE_STRENGTH", "0.34"))
        self.outline_strength = float(os.getenv("OPENCV_OUTLINE_STRENGTH", "0.48"))

    def transform_frame(
        self,
        frame: np.ndarray,
        context: FrameTransformContext,
    ) -> np.ndarray:
        return create_ink_wash_style(
            image=frame,
            ink_strength=self.ink_strength,
            wash_strength=self.wash_strength,
            paper_strength=self.paper_strength,
            white_space=self.white_space,
            detail_levels=self.detail_levels,
            texture_strength=self.texture_strength,
            detail_preserve=self.detail_preserve,
            fine_line_strength=self.fine_line_strength,
            outline_strength=self.outline_strength,
            seed=42 + context.shot_index,
        )


def create_paper_texture(height: int, width: int, seed: int = 42) -> np.ndarray:
    import cv2

    rng = np.random.default_rng(seed)
    fine_noise = rng.normal(loc=0, scale=7, size=(height, width)).astype(np.float32)

    coarse_h = max(2, height // 40)
    coarse_w = max(2, width // 40)
    coarse_noise = rng.normal(loc=0, scale=18, size=(coarse_h, coarse_w)).astype(np.float32)
    coarse_noise = cv2.resize(coarse_noise, (width, height), interpolation=cv2.INTER_CUBIC)
    coarse_noise = cv2.GaussianBlur(coarse_noise, (0, 0), sigmaX=12)

    paper = 239 + fine_noise + coarse_noise
    return np.clip(paper, 205, 255).astype(np.uint8)


def create_ink_grain(height: int, width: int, seed: int = 42) -> np.ndarray:
    import cv2

    rng = np.random.default_rng(seed + 1000)
    vertical = rng.normal(loc=0, scale=10, size=(height, max(2, width // 18))).astype(np.float32)
    vertical = cv2.resize(vertical, (width, height), interpolation=cv2.INTER_CUBIC)
    vertical = cv2.GaussianBlur(vertical, (0, 0), sigmaX=5, sigmaY=0.8)

    mottled = rng.normal(loc=0, scale=9, size=(max(2, height // 18), max(2, width // 18))).astype(np.float32)
    mottled = cv2.resize(mottled, (width, height), interpolation=cv2.INTER_CUBIC)
    mottled = cv2.GaussianBlur(mottled, (0, 0), sigmaX=4)

    grain = 128 + vertical + mottled
    return np.clip(grain, 70, 185).astype(np.uint8)


def quantize_gray(gray: np.ndarray, levels: int = 7) -> np.ndarray:
    if levels < 2:
        raise ValueError("levels must be 2 or greater.")

    step = 255 / (levels - 1)
    quantized = np.round(gray / step) * step
    return np.clip(quantized, 0, 255).astype(np.uint8)


def create_ink_lines(
    gray: np.ndarray,
    line_strength: float = 0.82,
    bleed_size: int = 5,
) -> np.ndarray:
    import cv2

    smooth = cv2.bilateralFilter(gray, d=9, sigmaColor=55, sigmaSpace=55)
    edges = cv2.adaptiveThreshold(
        smooth,
        255,
        cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
        cv2.THRESH_BINARY,
        blockSize=15,
        C=7,
    )

    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (3, 3))
    thickened = cv2.erode(edges, kernel, iterations=1)

    bleed_size = max(3, bleed_size)
    if bleed_size % 2 == 0:
        bleed_size += 1

    bleed = cv2.GaussianBlur(thickened, (bleed_size, bleed_size), sigmaX=1.2)
    ink_lines = cv2.addWeighted(
        edges.astype(np.float32),
        1.0 - line_strength,
        bleed.astype(np.float32),
        line_strength,
        0,
    )
    return np.clip(ink_lines, 0, 255).astype(np.uint8)


def create_thin_dark_outlines(gray: np.ndarray, strength: float = 0.55) -> np.ndarray:
    import cv2

    strength = float(np.clip(strength, 0.0, 1.0))
    if strength <= 0:
        return np.full_like(gray, 255)

    smooth = cv2.bilateralFilter(gray, d=5, sigmaColor=34, sigmaSpace=34)
    adaptive = cv2.adaptiveThreshold(
        smooth,
        255,
        cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
        cv2.THRESH_BINARY,
        blockSize=13,
        C=4,
    )
    canny = cv2.bitwise_not(cv2.Canny(smooth, threshold1=38, threshold2=105))
    lines = cv2.min(adaptive, canny)
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (2, 2))
    lines = cv2.morphologyEx(lines, cv2.MORPH_OPEN, kernel, iterations=1)

    soft_lines = cv2.GaussianBlur(lines, (3, 3), sigmaX=0.35)
    return cv2.addWeighted(lines, strength, soft_lines, 1.0 - strength, 0)


def create_ink_wash_style(
    image: np.ndarray,
    ink_strength: float = 0.8,
    wash_strength: float = 0.72,
    paper_strength: float = 0.25,
    white_space: float = 0.18,
    detail_levels: int = 7,
    texture_strength: float = 0.18,
    detail_preserve: float = 0.32,
    fine_line_strength: float = 0.28,
    outline_strength: float = 0.55,
    seed: int = 42,
) -> np.ndarray:
    import cv2

    if image is None or image.size == 0:
        raise ValueError("Input image is empty.")

    ink_strength = float(np.clip(ink_strength, 0.0, 1.0))
    wash_strength = float(np.clip(wash_strength, 0.0, 1.0))
    paper_strength = float(np.clip(paper_strength, 0.0, 1.0))
    white_space = float(np.clip(white_space, 0.0, 1.0))
    texture_strength = float(np.clip(texture_strength, 0.0, 1.0))
    detail_preserve = float(np.clip(detail_preserve, 0.0, 1.0))
    fine_line_strength = float(np.clip(fine_line_strength, 0.0, 1.0))
    outline_strength = float(np.clip(outline_strength, 0.0, 1.0))

    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

    clahe = cv2.createCLAHE(clipLimit=1.8, tileGridSize=(8, 8))
    contrast = clahe.apply(gray)

    smooth = cv2.bilateralFilter(contrast, d=7, sigmaColor=48, sigmaSpace=48)
    wash = cv2.GaussianBlur(smooth, (0, 0), sigmaX=3.2)
    wash = quantize_gray(wash, levels=detail_levels)

    white_threshold = int(180 - white_space * 35)
    bright_mask = cv2.threshold(wash, white_threshold, 255, cv2.THRESH_BINARY)[1]
    bright_mask = cv2.GaussianBlur(bright_mask, (9, 9), sigmaX=2)

    lifted_wash = cv2.addWeighted(wash, 1.0, bright_mask, white_space, 0)
    lines = create_ink_lines(contrast, line_strength=ink_strength, bleed_size=7)
    fine_edges = cv2.Canny(contrast, threshold1=54, threshold2=132)
    fine_edges = 255 - cv2.GaussianBlur(fine_edges, (3, 3), sigmaX=0.6)
    lines = cv2.multiply(lines, fine_edges, scale=1.0 / 255.0)

    combined = cv2.multiply(lifted_wash, lines, scale=1.0 / 255.0)
    soft_combined = cv2.GaussianBlur(combined, (3, 3), sigmaX=0.45)
    combined = cv2.addWeighted(combined, wash_strength, soft_combined, 1.0 - wash_strength, 0)

    detail = cv2.subtract(contrast, cv2.GaussianBlur(contrast, (0, 0), sigmaX=2.0))
    detail = cv2.normalize(detail, None, alpha=0, beta=255, norm_type=cv2.NORM_MINMAX)
    detail_layer = cv2.addWeighted(contrast, 0.65, detail, 0.35, 0)
    combined = cv2.addWeighted(combined, 1.0 - detail_preserve, detail_layer, detail_preserve, 0)

    if fine_line_strength > 0:
        combined = cv2.multiply(combined, fine_edges, scale=1.0 / 255.0)
        combined = cv2.addWeighted(combined, 1.0, lines, fine_line_strength * 0.12, 0)

    thin_outlines = create_thin_dark_outlines(contrast, strength=outline_strength)
    combined = cv2.multiply(combined, thin_outlines, scale=1.0 / 255.0)

    height, width = gray.shape
    paper = create_paper_texture(height, width, seed=seed)
    result_gray = cv2.addWeighted(combined, 1.0 - paper_strength, paper, paper_strength, 0)

    if texture_strength > 0:
        grain = create_ink_grain(height, width, seed=seed)
        dark_regions = 255 - cv2.GaussianBlur(result_gray, (0, 0), sigmaX=3.2)
        dark_regions = cv2.normalize(dark_regions, None, alpha=0, beta=1, norm_type=cv2.NORM_MINMAX).astype(np.float32)
        grain_effect = (grain.astype(np.float32) - 128) * dark_regions * texture_strength
        result_gray = np.clip(result_gray.astype(np.float32) + grain_effect, 0, 255).astype(np.uint8)
        result_gray = cv2.medianBlur(result_gray, 3)

    result_bgr = cv2.cvtColor(result_gray, cv2.COLOR_GRAY2BGR).astype(np.float32)
    paper_tint = np.full_like(result_bgr, (218, 232, 239), dtype=np.float32)
    result_bgr = cv2.addWeighted(result_bgr, 0.88, paper_tint, 0.12, 0)

    return np.clip(result_bgr, 0, 255).astype(np.uint8)
