import os

import numpy as np

from app.models.base import FrameTransformContext


class OpenCVMinhwaAdapter:
    """Deterministic OpenCV Minhwa-style adapter for every video frame."""

    name = "opencv-minhwa"

    def __init__(self) -> None:
        self.palette_strength = float(os.getenv("OPENCV_MINHWA_PALETTE_STRENGTH", "0.84"))
        self.outline_strength = float(os.getenv("OPENCV_MINHWA_OUTLINE_STRENGTH", "0.88"))
        self.line_thickness = int(os.getenv("OPENCV_MINHWA_LINE_THICKNESS", "1"))
        self.flatten_strength = float(os.getenv("OPENCV_MINHWA_FLATTEN_STRENGTH", "0.66"))
        self.smoothing_strength = float(os.getenv("OPENCV_MINHWA_SMOOTHING_STRENGTH", "0.30"))
        self.paper_strength = float(os.getenv("OPENCV_MINHWA_PAPER_STRENGTH", "0.28"))
        self.pigment_bleed = float(os.getenv("OPENCV_MINHWA_PIGMENT_BLEED", "0.00"))
        self.hand_drawn_strength = float(os.getenv("OPENCV_MINHWA_HAND_DRAWN_STRENGTH", "0.03"))
        self.paint_variation = float(os.getenv("OPENCV_MINHWA_PAINT_VARIATION", "0.015"))
        self.age_strength = float(os.getenv("OPENCV_MINHWA_AGE_STRENGTH", "0.58"))
        self.preserve_brightness = float(os.getenv("OPENCV_MINHWA_PRESERVE_BRIGHTNESS", "0.22"))
        self.color_fade = float(os.getenv("OPENCV_MINHWA_COLOR_FADE", "0.16"))
        self.color_boost = float(os.getenv("OPENCV_MINHWA_COLOR_BOOST", "0.62"))
        self.ink_tone_strength = float(os.getenv("OPENCV_MINHWA_INK_TONE_STRENGTH", "0.84"))
        self.sharpness = float(os.getenv("OPENCV_MINHWA_SHARPNESS", "0.52"))
        self.temporal_blend = float(os.getenv("OPENCV_MINHWA_TEMPORAL_BLEND", "0.00"))

    def transform_frame(
        self,
        frame: np.ndarray,
        context: FrameTransformContext,
    ) -> np.ndarray:
        result = create_minhwa_style(
            image=frame,
            palette_strength=self.palette_strength,
            outline_strength=self.outline_strength,
            line_thickness=self.line_thickness,
            flatten_strength=self.flatten_strength,
            smoothing_strength=self.smoothing_strength,
            paper_strength=self.paper_strength,
            pigment_bleed=self.pigment_bleed,
            hand_drawn_strength=self.hand_drawn_strength,
            paint_variation=self.paint_variation,
            age_strength=self.age_strength,
            preserve_brightness=self.preserve_brightness,
            color_fade=self.color_fade,
            color_boost=self.color_boost,
            ink_tone_strength=self.ink_tone_strength,
            sharpness=self.sharpness,
            seed=120 + context.shot_index,
        )

        if self.temporal_blend > 0 and context.previous_styled_frame_path is not None:
            try:
                import cv2

                previous = cv2.imread(str(context.previous_styled_frame_path), cv2.IMREAD_COLOR)
                if previous is not None and previous.shape[:2] == result.shape[:2]:
                    alpha = clamp01(self.temporal_blend)
                    result = cv2.addWeighted(result, 1.0 - alpha, previous, alpha, 0)
            except Exception:
                pass

        return result


def clamp01(value: float) -> float:
    return float(np.clip(value, 0.0, 1.0))


def create_old_hanji_texture(
    height: int,
    width: int,
    seed: int = 42,
    age_strength: float = 0.55,
) -> np.ndarray:
    import cv2

    age_strength = clamp01(age_strength)
    rng = np.random.default_rng(seed)

    paper = np.zeros((height, width, 3), dtype=np.float32)
    paper[:, :, 0] = 186
    paper[:, :, 1] = 210
    paper[:, :, 2] = 222

    fine_noise = rng.normal(
        loc=0,
        scale=4.0 + 5.0 * age_strength,
        size=(height, width),
    ).astype(np.float32)

    small_h = max(3, height // 45)
    small_w = max(3, width // 45)
    coarse_noise = rng.normal(
        loc=0,
        scale=12.0 + 18.0 * age_strength,
        size=(small_h, small_w),
    ).astype(np.float32)
    coarse_noise = cv2.resize(coarse_noise, (width, height), interpolation=cv2.INTER_CUBIC)
    coarse_noise = cv2.GaussianBlur(coarse_noise, (0, 0), sigmaX=18)

    stain_count = max(4, int((height * width) / 150000))
    stains = np.zeros((height, width), dtype=np.float32)
    for _ in range(stain_count):
        cx = int(rng.integers(0, width))
        cy = int(rng.integers(0, height))
        radius_x = int(rng.integers(max(10, width // 20), max(20, width // 7)))
        radius_y = int(rng.integers(max(10, height // 20), max(20, height // 7)))
        intensity = float(rng.uniform(4, 15)) * age_strength
        cv2.ellipse(stains, (cx, cy), (radius_x, radius_y), 0, 0, 360, intensity, -1)

    stains = cv2.GaussianBlur(stains, (0, 0), sigmaX=30)
    texture = fine_noise + coarse_noise - stains
    paper += texture[:, :, None]

    yy, xx = np.mgrid[0:height, 0:width].astype(np.float32)
    center_x = width / 2.0
    center_y = height / 2.0
    distance = np.sqrt(
        ((xx - center_x) / max(center_x, 1)) ** 2
        + ((yy - center_y) / max(center_y, 1)) ** 2
    )
    vignette = np.clip(distance - 0.55, 0, 1) * 18.0 * age_strength
    paper -= vignette[:, :, None]

    return np.clip(paper, 0, 255).astype(np.uint8)


def get_minhwa_palette() -> np.ndarray:
    return np.array(
        [
            [188, 211, 222],
            [163, 190, 207],
            [119, 142, 158],
            [47, 54, 58],
            [24, 27, 30],
            [73, 87, 110],
            [62, 73, 166],
            [68, 100, 192],
            [62, 112, 72],
            [82, 152, 92],
            [78, 139, 58],
            [86, 94, 48],
            [118, 91, 52],
            [205, 168, 71],
            [36, 51, 148],
            [45, 64, 186],
            [129, 114, 145],
            [178, 167, 196],
        ],
        dtype=np.float32,
    )


def map_to_palette(image: np.ndarray, palette: np.ndarray) -> np.ndarray:
    pixels = image.reshape(-1, 3).astype(np.float32)
    mapped = np.empty_like(pixels)
    chunk_size = 100_000

    for start in range(0, len(pixels), chunk_size):
        end = min(start + chunk_size, len(pixels))
        chunk = pixels[start:end]
        distances = np.sum((chunk[:, None, :] - palette[None, :, :]) ** 2, axis=2)
        nearest = np.argmin(distances, axis=1)
        mapped[start:end] = palette[nearest]

    return mapped.reshape(image.shape).astype(np.uint8)


def simplify_color_regions(image: np.ndarray, smoothing_strength: float = 0.7) -> np.ndarray:
    import cv2

    smoothing_strength = clamp01(smoothing_strength)
    sigma_s = int(28 + 55 * smoothing_strength)
    sigma_r = 0.16 + 0.24 * smoothing_strength

    smoothed = cv2.edgePreservingFilter(
        image,
        flags=cv2.RECURS_FILTER,
        sigma_s=sigma_s,
        sigma_r=sigma_r,
    )
    return cv2.bilateralFilter(
        smoothed,
        d=7,
        sigmaColor=28 + 32 * smoothing_strength,
        sigmaSpace=28 + 32 * smoothing_strength,
    )


def reduce_light_and_shadow(image: np.ndarray, flatten_strength: float = 0.65) -> np.ndarray:
    import cv2

    flatten_strength = clamp01(flatten_strength)
    lab = cv2.cvtColor(image, cv2.COLOR_BGR2LAB).astype(np.float32)
    lightness = lab[:, :, 0]
    local_average = cv2.GaussianBlur(lightness, (0, 0), sigmaX=12)
    lab[:, :, 0] = np.clip(
        cv2.addWeighted(lightness, 1.0 - flatten_strength, local_average, flatten_strength, 0),
        0,
        255,
    )
    return cv2.cvtColor(lab.astype(np.uint8), cv2.COLOR_LAB2BGR)


def create_minhwa_outline(
    image: np.ndarray,
    outline_strength: float = 0.8,
    line_thickness: int = 2,
) -> np.ndarray:
    import cv2

    outline_strength = clamp01(outline_strength)
    line_thickness = max(1, int(line_thickness))
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    gray = cv2.bilateralFilter(gray, d=5, sigmaColor=24, sigmaSpace=24)

    adaptive = cv2.adaptiveThreshold(
        gray,
        255,
        cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
        cv2.THRESH_BINARY,
        blockSize=13,
        C=3,
    )
    canny = cv2.bitwise_not(cv2.Canny(gray, threshold1=30, threshold2=88))
    edges = cv2.min(adaptive, canny)

    kernel_size = 2 * line_thickness + 1
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (kernel_size, kernel_size))
    clean_kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (2, 2))
    edges = cv2.morphologyEx(edges, cv2.MORPH_OPEN, clean_kernel, iterations=1)
    thick_edges = cv2.erode(edges, kernel, iterations=1)
    outline = cv2.addWeighted(edges, 0.58, thick_edges, 0.42, 0)
    outline = cv2.addWeighted(edges, 1.0 - outline_strength, outline, outline_strength, 0)
    return cv2.cvtColor(outline, cv2.COLOR_GRAY2BGR)


def tint_outline_to_aged_ink(outline: np.ndarray, strength: float = 0.70) -> np.ndarray:
    strength = clamp01(strength)
    if strength <= 0:
        return outline

    ink_tint = np.zeros_like(outline)
    ink_tint[:, :, 0] = 22
    ink_tint[:, :, 1] = 26
    ink_tint[:, :, 2] = 31

    darkness = 255 - outline
    alpha = (darkness.astype(np.float32) / 255.0)[:, :, :1] * strength
    toned = outline.astype(np.float32) * (1.0 - alpha) + ink_tint.astype(np.float32) * alpha
    return np.clip(toned, 0, 255).astype(np.uint8)


def boost_minhwa_colors(image: np.ndarray, strength: float = 0.30) -> np.ndarray:
    import cv2

    strength = clamp01(strength)
    if strength <= 0:
        return image

    hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV).astype(np.float32)
    hue = hsv[:, :, 0]
    saturation = hsv[:, :, 1]
    value = hsv[:, :, 2]

    color_mask = saturation > 15
    red_mask = ((hue <= 12) | (hue >= 165)) & color_mask
    green_mask = ((hue >= 35) & (hue <= 85)) & color_mask
    ocher_mask = ((hue >= 12) & (hue <= 34)) & color_mask
    blue_mask = ((hue >= 90) & (hue <= 130)) & color_mask

    saturation[color_mask] *= 1.0 + 0.65 * strength
    saturation[red_mask | green_mask | ocher_mask | blue_mask] *= 1.0 + 0.75 * strength
    value[color_mask] *= 1.0 - 0.05 * strength
    value[red_mask | green_mask | ocher_mask | blue_mask] *= 1.0 + 0.08 * strength

    hsv[:, :, 1] = np.clip(saturation, 0, 255)
    hsv[:, :, 2] = np.clip(value, 0, 255)
    return cv2.cvtColor(hsv.astype(np.uint8), cv2.COLOR_HSV2BGR)


def add_hand_drawn_line_variation(
    outline: np.ndarray,
    strength: float = 0.25,
    seed: int = 123,
) -> np.ndarray:
    import cv2

    strength = clamp01(strength)
    if strength <= 0:
        return outline

    height, width = outline.shape[:2]
    rng = np.random.default_rng(seed)
    grid_h = max(3, height // 40)
    grid_w = max(3, width // 40)

    dx_small = rng.normal(0, 1.5 * strength, (grid_h, grid_w)).astype(np.float32)
    dy_small = rng.normal(0, 1.5 * strength, (grid_h, grid_w)).astype(np.float32)
    dx = cv2.resize(dx_small, (width, height), interpolation=cv2.INTER_CUBIC)
    dy = cv2.resize(dy_small, (width, height), interpolation=cv2.INTER_CUBIC)
    xx, yy = np.meshgrid(
        np.arange(width, dtype=np.float32),
        np.arange(height, dtype=np.float32),
    )

    warped = cv2.remap(
        outline,
        xx + dx,
        yy + dy,
        interpolation=cv2.INTER_LINEAR,
        borderMode=cv2.BORDER_REFLECT,
    )
    return cv2.addWeighted(outline, 0.45, warped, 0.55, 0)


def add_pigment_bleed(image: np.ndarray, bleed_strength: float = 0.12) -> np.ndarray:
    import cv2

    bleed_strength = clamp01(bleed_strength)
    if bleed_strength <= 0:
        return image

    blur = cv2.GaussianBlur(image, (0, 0), sigmaX=1.3 + bleed_strength * 2.5)
    return cv2.addWeighted(image, 1.0 - bleed_strength, blur, bleed_strength, 0)


def sharpen_image(image: np.ndarray, sharpness: float = 0.45) -> np.ndarray:
    import cv2

    sharpness = clamp01(sharpness)
    if sharpness <= 0:
        return image

    blurred = cv2.GaussianBlur(image, (0, 0), sigmaX=0.65)
    sharpened = cv2.addWeighted(image, 1.0 + sharpness * 1.25, blurred, -sharpness * 1.25, 0)
    return np.clip(sharpened, 0, 255).astype(np.uint8)


def add_manual_paint_variation(
    image: np.ndarray,
    strength: float = 0.10,
    seed: int = 77,
) -> np.ndarray:
    import cv2

    strength = clamp01(strength)
    if strength <= 0:
        return image

    height, width = image.shape[:2]
    rng = np.random.default_rng(seed)
    small_noise = rng.normal(0, 1, (max(3, height // 35), max(3, width // 35))).astype(np.float32)
    noise = cv2.resize(small_noise, (width, height), interpolation=cv2.INTER_CUBIC)
    noise = cv2.GaussianBlur(noise, (0, 0), sigmaX=4)
    noise = noise / (np.std(noise) + 1e-6)
    noise *= 8.0 * strength

    result = image.astype(np.float32)
    result += noise[:, :, None]
    return np.clip(result, 0, 255).astype(np.uint8)


def create_minhwa_style(
    image: np.ndarray,
    palette_strength: float = 0.90,
    outline_strength: float = 0.85,
    line_thickness: int = 1,
    flatten_strength: float = 0.72,
    smoothing_strength: float = 0.78,
    paper_strength: float = 0.20,
    pigment_bleed: float = 0.10,
    hand_drawn_strength: float = 0.20,
    paint_variation: float = 0.08,
    age_strength: float = 0.50,
    preserve_brightness: float = 0.20,
    color_fade: float = 0.34,
    color_boost: float = 0.30,
    ink_tone_strength: float = 0.70,
    sharpness: float = 0.45,
    seed: int = 42,
) -> np.ndarray:
    import cv2

    if image is None or image.size == 0:
        raise ValueError("Input image is empty.")

    palette_strength = clamp01(palette_strength)
    outline_strength = clamp01(outline_strength)
    flatten_strength = clamp01(flatten_strength)
    smoothing_strength = clamp01(smoothing_strength)
    paper_strength = clamp01(paper_strength)
    pigment_bleed = clamp01(pigment_bleed)
    hand_drawn_strength = clamp01(hand_drawn_strength)
    paint_variation = clamp01(paint_variation)
    age_strength = clamp01(age_strength)
    preserve_brightness = clamp01(preserve_brightness)
    color_fade = clamp01(color_fade)
    color_boost = clamp01(color_boost)
    ink_tone_strength = clamp01(ink_tone_strength)
    sharpness = clamp01(sharpness)

    height, width = image.shape[:2]
    smoothed = simplify_color_regions(image, smoothing_strength=smoothing_strength)
    flattened = reduce_light_and_shadow(smoothed, flatten_strength=flatten_strength)
    palette_image = map_to_palette(flattened, get_minhwa_palette())

    colored = cv2.addWeighted(
        palette_image,
        palette_strength,
        flattened,
        1.0 - palette_strength,
        0,
    )

    original_gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    original_gray = cv2.GaussianBlur(original_gray, (0, 0), sigmaX=3)
    original_gray_bgr = cv2.cvtColor(original_gray, cv2.COLOR_GRAY2BGR)
    colored = cv2.addWeighted(
        colored,
        1.0 - preserve_brightness,
        original_gray_bgr,
        preserve_brightness,
        0,
    )

    paper = create_old_hanji_texture(height, width, seed=seed + 53, age_strength=age_strength)
    colored = cv2.addWeighted(colored, 1.0 - color_fade, paper, color_fade, 0)
    colored = boost_minhwa_colors(colored, strength=color_boost)
    colored = add_manual_paint_variation(colored, strength=paint_variation, seed=seed + 17)
    colored = add_pigment_bleed(colored, bleed_strength=pigment_bleed)

    outline = create_minhwa_outline(
        image,
        outline_strength=outline_strength,
        line_thickness=line_thickness,
    )
    outline = add_hand_drawn_line_variation(
        outline,
        strength=hand_drawn_strength,
        seed=seed + 31,
    )
    outline = tint_outline_to_aged_ink(outline, strength=ink_tone_strength)

    inked = cv2.multiply(colored, outline, scale=1.0 / 255.0)
    inked = cv2.addWeighted(inked, outline_strength, colored, 1.0 - outline_strength, 0)

    result = cv2.addWeighted(inked, 1.0 - paper_strength, paper, paper_strength, 0)
    return sharpen_image(result, sharpness=sharpness)
