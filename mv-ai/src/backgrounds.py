from __future__ import annotations

import hashlib
from pathlib import Path

import cv2
import numpy as np
from PIL import Image, ImageDraw, ImageEnhance, ImageOps


PALETTES = {
    "moon_mountain": ((224, 226, 218), (56, 70, 78), (128, 137, 131)),
    "mist_river": ((230, 226, 211), (49, 65, 61), (111, 132, 126)),
    "bamboo_dawn": ((229, 226, 204), (46, 73, 56), (117, 135, 89)),
    "palace_festival": ((225, 214, 195), (75, 49, 45), (151, 65, 51)),
    "red_sunset": ((224, 207, 180), (75, 56, 55), (164, 76, 53)),
    "storm_mountain": ((211, 216, 213), (38, 48, 53), (92, 105, 109)),
    "spring_palace": ((234, 224, 211), (58, 72, 62), (165, 105, 104)),
    "lotus_lake": ((226, 224, 208), (50, 75, 69), (143, 104, 116)),
}


def _seed(name: str) -> int:
    return int(hashlib.sha256(name.encode("utf-8")).hexdigest()[:8], 16)


def generate_background(name: str, size: tuple[int, int]) -> Image.Image:
    width, height = size
    paper, ink, accent = PALETTES.get(name, PALETTES["mist_river"])
    rng = np.random.default_rng(_seed(name))
    noise = rng.normal(0, 5, (height, width, 1))
    base = np.clip(np.array(paper, dtype=np.float32) + noise, 0, 255)
    base = np.repeat(base, 1, axis=2).astype(np.uint8)
    image = Image.fromarray(base)
    draw = ImageDraw.Draw(image, "RGBA")

    # Layered mountain silhouettes imitate diluted ink on textured paper.
    for layer in range(4):
        baseline = int(height * (0.48 + layer * 0.11))
        points = [(0, height)]
        x = -width // 8
        while x < width + width // 8:
            peak_y = baseline - int(rng.uniform(height * 0.08, height * (0.3 - layer * 0.035)))
            points.extend([(x, baseline), (x + int(rng.uniform(90, 210)), peak_y)])
            x += int(rng.uniform(180, 340))
        points.extend([(width, baseline), (width, height)])
        alpha = 48 + layer * 27
        color = (*ink, alpha)
        draw.polygon(points, fill=color)

    if "moon" in name:
        radius = int(height * 0.085)
        center = (int(width * 0.76), int(height * 0.22))
        draw.ellipse(
            (center[0] - radius, center[1] - radius, center[0] + radius, center[1] + radius),
            fill=(244, 239, 209, 220),
        )
    if "palace" in name or "festival" in name:
        y = int(height * 0.59)
        draw.rectangle((int(width * 0.18), y, int(width * 0.82), int(height * 0.78)), fill=(*ink, 105))
        draw.polygon(
            [(int(width * 0.12), y), (width // 2, int(height * 0.46)), (int(width * 0.88), y)],
            fill=(*accent, 150),
        )
    if "bamboo" in name:
        for x in (0.12, 0.2, 0.82, 0.9):
            px = int(width * x)
            draw.line((px, int(height * 0.12), px - 30, height), fill=(*ink, 100), width=8)
            for y in range(int(height * 0.22), int(height * 0.75), 90):
                draw.ellipse((px - 42, y, px + 8, y + 18), fill=(*accent, 100))

    # A subtle OpenCV blur softens hard procedural edges into ink washes.
    array = cv2.GaussianBlur(np.asarray(image), (0, 0), sigmaX=1.1)
    return Image.fromarray(array)


def load_background(path: Path, size: tuple[int, int]) -> Image.Image:
    with Image.open(path) as source:
        image = ImageOps.exif_transpose(source).convert("RGB")
        image = ImageOps.fit(image, size, method=Image.Resampling.LANCZOS)
        image = ImageEnhance.Color(image).enhance(0.72)
        return image.copy()
