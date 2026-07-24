from __future__ import annotations

import math
import os
import shutil
import subprocess
from functools import lru_cache
from pathlib import Path
from typing import Any

import cv2
import imageio_ffmpeg
import numpy as np
from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageOps

from backgrounds import generate_background, load_background


ASSET_ROOT = Path(__file__).resolve().parents[1] / "assets"
PACKAGED_BACKGROUND_ORDER = (
    "ink-moon-mountains.png",
    "ink-mountain-river.png",
    "ink-waterfall-valley.png",
)
INK_ASSET_ORDER = (
    "ink-burst.png",
    "ink-wash.png",
    "ink-circle.png",
    "ink-sweep.png",
)
BRUSH_ASSET_ORDER = (
    "brush-horizontal.png",
    "brush-diagonal-wide.png",
    "brush-diagonal-fine.png",
    "brush-circle.png",
)
FOG_ASSET_ORDER = (
    "fog-wide.png",
    "fog-soft-left.png",
    "fog-soft-right.png",
    "fog-light.png",
    "fog-dark.png",
)


def _ffmpeg_executable() -> str:
    configured = os.getenv("FFMPEG_BINARY")
    if configured:
        return configured
    system = shutil.which("ffmpeg")
    return system or imageio_ffmpeg.get_ffmpeg_exe()


def _signal(analysis: dict[str, Any], key: str, time: float) -> float:
    samples = analysis["samples"]
    if not samples:
        return 0.0
    index = min(int(time * 10), len(samples) - 1)
    current = samples[index]
    following = samples[min(index + 1, len(samples) - 1)]
    progress = min(1.0, max(0.0, time * 10 - index))
    return float(current[key]) * (1 - progress) + float(following[key]) * progress


def _scene_at(direction: dict[str, Any], time: float) -> tuple[int, dict[str, Any]]:
    scenes = direction["scenes"]
    for index, scene in enumerate(scenes):
        if float(scene["start"]) <= time < float(scene["end"]):
            return index, scene
    return len(scenes) - 1, scenes[-1]


def _ink_mask(size: tuple[int, int], progress: float, seed: int) -> Image.Image:
    width, height = size
    mask_width, mask_height = max(80, width // 4), max(45, height // 4)
    rng = np.random.default_rng(seed)
    mask = np.zeros((mask_height, mask_width), dtype=np.uint8)
    center = (
        int(mask_width * rng.uniform(0.3, 0.7)),
        int(mask_height * rng.uniform(0.3, 0.7)),
    )
    radius = int(math.hypot(mask_width, mask_height) * max(0.01, progress) * 0.8)
    for _ in range(13):
        offset = int(radius * 0.32)
        point = (
            center[0] + int(rng.integers(-offset, offset + 1)) if offset else center[0],
            center[1] + int(rng.integers(-offset, offset + 1)) if offset else center[1],
        )
        blob_radius = max(1, int(radius * rng.uniform(0.34, 0.62)))
        cv2.circle(mask, point, blob_radius, 255, -1, lineType=cv2.LINE_AA)
    mask = cv2.GaussianBlur(mask, (0, 0), sigmaX=max(1, mask_width * 0.006))
    mask = cv2.resize(mask, size, interpolation=cv2.INTER_LINEAR)
    return Image.fromarray(mask)


@lru_cache(maxsize=96)
def _ink_texture_mask(
    path: str,
    size: tuple[int, int],
    crop_to_fill: bool = True,
) -> Image.Image:
    with Image.open(path) as source:
        rgba = source.convert("RGBA")
        array = np.asarray(rgba, dtype=np.float32)
        darkness = 255.0 - np.mean(array[:, :, :3], axis=2)
        alpha = array[:, :, 3] * (0.38 + 0.62 * darkness / 255.0)
        mask = Image.fromarray(np.clip(alpha, 0, 255).astype(np.uint8))
        if crop_to_fill:
            return ImageOps.fit(mask, size, method=Image.Resampling.LANCZOS)
        contained = ImageOps.contain(mask, size, method=Image.Resampling.LANCZOS)
        canvas = Image.new("L", size, 0)
        canvas.paste(
            contained,
            ((size[0] - contained.width) // 2, (size[1] - contained.height) // 2),
        )
        return canvas


def _brush_reveal_mask(
    size: tuple[int, int],
    progress: float,
    ink_path: Path | None,
) -> Image.Image:
    width, height = size
    eased = progress * progress * (3.0 - 2.0 * progress)
    edge_width = max(120, int(width * 0.32))
    x = int(-edge_width + eased * (width + edge_width * 2))
    mask = Image.new("L", size, 0)
    draw = ImageDraw.Draw(mask)
    gradient_start = x - edge_width // 2
    gradient_end = x + edge_width // 2
    draw.rectangle((0, 0, max(0, gradient_start), height), fill=255)
    visible_start = max(0, gradient_start)
    visible_end = min(width, gradient_end)
    gradient_span = max(1, gradient_end - gradient_start)
    for column in range(visible_start, visible_end):
        ratio = (column - gradient_start) / gradient_span
        value = int(255 * (1.0 - ratio) ** 1.35)
        draw.line((column, 0, column, height), fill=value)
    if ink_path:
        edge = _ink_texture_mask(str(ink_path), (edge_width, int(height * 1.12)))
        edge = edge.filter(ImageFilter.GaussianBlur(radius=max(1, width // 500)))
        layer = Image.new("L", size, 0)
        layer.paste(edge, (x - edge_width // 2, -int(height * 0.06)))
        mask = ImageChops.lighter(mask, layer).filter(ImageFilter.GaussianBlur(radius=2))
    else:
        draw = ImageDraw.Draw(mask)
        draw.ellipse((x - edge_width // 2, -40, x + edge_width // 2, height + 40), fill=220)
    return mask


def _transition(
    current: Image.Image,
    previous: Image.Image,
    scene: dict[str, Any],
    time: float,
    ink_paths: list[Path],
) -> Image.Image:
    elapsed = time - float(scene["start"])
    if elapsed >= 1.25 or elapsed < 0:
        return current
    progress = min(1.0, elapsed / 1.25)
    if scene["transition"] == "brush":
        ink_path = ink_paths[int(scene["index"]) % len(ink_paths)] if ink_paths else None
        mask = _brush_reveal_mask(current.size, progress, ink_path)
    else:
        mask = _ink_mask(current.size, progress, int(scene["index"]) + 17)
    return Image.composite(current, previous, mask)


def _apply_fog(frame: Image.Image, time: float, strength: float) -> None:
    width, height = frame.size
    fog_size = (max(160, width // 4), max(90, height // 4))
    fog = Image.new("RGBA", fog_size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(fog)
    fog_width, fog_height = fog_size
    shift = int((time * 6) % (fog_width + 125)) - 62
    alpha = int(22 + 52 * strength)
    for index in range(4):
        x = shift + index * fog_width // 3
        y = int(fog_height * (0.35 + 0.12 * math.sin(time * 0.22 + index)))
        draw.ellipse((x - 75, y - 22, x + 105, y + 33), fill=(239, 240, 232, alpha))
    fog = fog.filter(ImageFilter.GaussianBlur(radius=18)).resize(frame.size, Image.Resampling.BILINEAR)
    frame.alpha_composite(fog)


@lru_cache(maxsize=64)
def _fog_sprite(path: str, target_width: int) -> Image.Image:
    with Image.open(path) as source:
        fog = source.convert("RGBA")
        scale = target_width / fog.width
        return fog.resize(
            (target_width, max(1, int(fog.height * scale))),
            Image.Resampling.LANCZOS,
        )


def _apply_asset_fog(
    frame: Image.Image,
    time: float,
    strength: float,
    fog_paths: list[Path],
) -> None:
    if not fog_paths:
        _apply_fog(frame, time, strength)
        return
    width, height = frame.size
    for layer in range(3):
        path = fog_paths[(int(time / 4.0) + layer) % len(fog_paths)]
        target_width = int(width * (0.62 + layer * 0.16))
        fog = _fog_sprite(str(path), target_width).copy()
        opacity = min(0.68, 0.18 + strength * 0.32 - layer * 0.035)
        fog.putalpha(fog.getchannel("A").point(lambda value: int(value * opacity)))
        travel = width + fog.width
        x = int((time * (9 + layer * 5) + layer * width * 0.37) % travel) - fog.width
        y = int(height * (0.25 + layer * 0.2) + math.sin(time * 0.18 + layer) * 18)
        frame.alpha_composite(fog, (x, y))
        if x + fog.width < width:
            frame.alpha_composite(fog, (x + travel, y))


@lru_cache(maxsize=768)
def _petal_variant(path: str, size: int, angle: int) -> Image.Image:
    with Image.open(path) as source:
        petal = source.convert("RGBA")
        scale = size / max(petal.size)
        resized = petal.resize(
            (max(1, int(petal.width * scale)), max(1, int(petal.height * scale))),
            Image.Resampling.LANCZOS,
        )
        return resized.rotate(angle, resample=Image.Resampling.BICUBIC, expand=True)


def _apply_petals(
    frame: Image.Image,
    time: float,
    strength: float,
    petal_paths: list[Path],
) -> None:
    width, height = frame.size
    count = 6 + int(strength * 12)
    for index in range(count):
        phase = index * 1.713
        x = (index * 137 + time * (19 + index % 5) + math.sin(time + phase) * 32) % (width + 60) - 30
        y = (index * 83 + time * (24 + index % 7)) % (height + 70) - 35
        if petal_paths:
            size = 16 + (index % 5) * 5 + int(strength * 7)
            angle = int((time * (35 + index % 4 * 9) + index * 53) % 360)
            angle = (angle // 15) * 15
            petal = _petal_variant(str(petal_paths[index % len(petal_paths)]), size, angle).copy()
            opacity = 0.52 + strength * 0.38
            petal.putalpha(petal.getchannel("A").point(lambda value: int(value * opacity)))
            frame.alpha_composite(petal, (int(x - petal.width / 2), int(y - petal.height / 2)))
        else:
            draw = ImageDraw.Draw(frame, "RGBA")
            radius = 3 + index % 4
            draw.ellipse(
                (x - radius * 2, y - radius, x + radius * 2, y + radius),
                fill=(174, 88, 94, 95 + int(80 * strength)),
            )


def _apply_ink_events(
    frame: Image.Image,
    events: list[dict[str, Any]],
    time: float,
    ink_paths: list[Path],
) -> None:
    overlay = Image.new("RGBA", frame.size, (0, 0, 0, 0))
    for index, event in enumerate(events):
        age = time - float(event["time"])
        if age < 0 or age > 1.15:
            continue
        strength = float(event["strength"])
        progress = min(1.0, age / 0.42)
        fade = max(0.0, 1.0 - age / 1.15)
        if ink_paths:
            source_path = ink_paths[index % len(ink_paths)]
            target_width = int(frame.width * (0.24 + strength * 0.25))
            target_height = max(1, int(target_width * 0.68))
            source_mask = _ink_texture_mask(
                str(source_path),
                (target_width, target_height),
                crop_to_fill=False,
            )
            reveal_width = int(source_mask.width * progress)
            reveal_gate = Image.new("L", source_mask.size, 0)
            gate_draw = ImageDraw.Draw(reveal_gate)
            feather = max(4, source_mask.width // 18)
            solid_end = max(0, reveal_width - feather)
            gate_draw.rectangle((0, 0, solid_end, source_mask.height), fill=255)
            for column in range(solid_end, min(source_mask.width, reveal_width + 1)):
                value = int(255 * (reveal_width - column) / max(1, feather))
                gate_draw.line((column, 0, column, source_mask.height), fill=max(0, value))
            revealed = ImageChops.multiply(source_mask, reveal_gate)
            mask = Image.new("L", frame.size, 0)
            x = int((index * 193) % max(1, frame.width - target_width))
            y = int((index * 109) % max(1, frame.height - target_height))
            mask.paste(revealed, (x, y))
        else:
            mask = _ink_mask(frame.size, progress * 0.22 * strength, index + 101)
        alpha = mask.point(lambda value: int(value * 0.28 * fade * strength))
        ink = Image.new("RGBA", frame.size, (19, 25, 27, 0))
        ink.putalpha(alpha)
        overlay.alpha_composite(ink)
    frame.alpha_composite(overlay)


def _backgrounds(
    direction: dict[str, Any],
    size: tuple[int, int],
    custom_paths: list[Path],
) -> list[Image.Image]:
    result = []
    packaged_paths = [
        ASSET_ROOT / "backgrounds" / name
        for name in PACKAGED_BACKGROUND_ORDER
        if (ASSET_ROOT / "backgrounds" / name).exists()
    ]
    for index, scene in enumerate(direction["scenes"]):
        if custom_paths:
            result.append(load_background(custom_paths[index % len(custom_paths)], size))
        elif packaged_paths:
            energy = min(1.0, max(0.0, float(scene.get("energy", 0.5))))
            background_index = min(len(packaged_paths) - 1, int(round(energy * (len(packaged_paths) - 1))))
            result.append(load_background(packaged_paths[background_index], size))
        else:
            result.append(generate_background(str(scene["background"]), size))
    return result


def render_video(
    audio_path: Path,
    output_path: Path,
    analysis: dict[str, Any],
    direction: dict[str, Any],
    custom_backgrounds: list[Path] | None = None,
) -> Path:
    config = direction["render"]
    width, height = int(config["width"]), int(config["height"])
    fps = int(config["fps"])
    duration = min(30.0, float(config["duration"]))
    size = (width, height)
    backgrounds = _backgrounds(direction, size, custom_backgrounds or [])
    petal_paths = sorted((ASSET_ROOT / "petals").glob("petal-??.png"))
    ink_paths = [
        ASSET_ROOT / "ink" / name
        for name in INK_ASSET_ORDER
        if (ASSET_ROOT / "ink" / name).exists()
    ]
    brush_paths = [
        ASSET_ROOT / "brushes" / name
        for name in BRUSH_ASSET_ORDER
        if (ASSET_ROOT / "brushes" / name).exists()
    ]
    fog_paths = [
        ASSET_ROOT / "fog" / name
        for name in FOG_ASSET_ORDER
        if (ASSET_ROOT / "fog" / name).exists()
    ]
    effect_paths = ink_paths + brush_paths[1:]
    output_path.parent.mkdir(parents=True, exist_ok=True)

    command = [
        _ffmpeg_executable(),
        "-hide_banner", "-loglevel", "error", "-y",
        "-f", "rawvideo", "-pix_fmt", "rgb24", "-s", f"{width}x{height}",
        "-r", str(fps), "-i", "pipe:0",
        "-ss", str(analysis["sourceStart"]), "-t", str(duration), "-i", str(audio_path),
        "-map", "0:v:0", "-map", "1:a:0",
        "-c:v", "libx264", "-preset", os.getenv("MV_FFMPEG_PRESET", "veryfast"),
        "-crf", os.getenv("MV_FFMPEG_CRF", "24"), "-pix_fmt", "yuv420p",
        "-c:a", "aac", "-b:a", "160k", "-movflags", "+faststart", "-shortest",
        str(output_path),
    ]
    process = subprocess.Popen(command, stdin=subprocess.PIPE, stderr=subprocess.PIPE)
    try:
        assert process.stdin is not None
        total_frames = max(1, int(math.ceil(duration * fps)))
        for frame_number in range(total_frames):
            time = frame_number / fps
            scene_index, scene = _scene_at(direction, time)
            base = backgrounds[scene_index]
            if scene_index:
                transition_paths = brush_paths[:1] or ink_paths
                base = _transition(base, backgrounds[scene_index - 1], scene, time, transition_paths)
            frame = base.convert("RGBA")
            energy = _signal(analysis, "energy", time)
            high = _signal(analysis, "highBand", time)
            _apply_asset_fog(frame, time, 0.35 + (1.0 - energy) * 0.5, fog_paths)
            _apply_petals(frame, time, high, petal_paths)
            _apply_ink_events(frame, direction["inkEvents"], time, effect_paths)
            process.stdin.write(frame.convert("RGB").tobytes())
        process.stdin.close()
        stderr = process.stderr.read().decode("utf-8", errors="replace") if process.stderr else ""
        return_code = process.wait()
        if return_code:
            raise RuntimeError(f"FFmpeg failed with exit code {return_code}: {stderr[-2000:]}")
    except Exception:
        if process.poll() is None:
            process.kill()
        output_path.unlink(missing_ok=True)
        raise
    if not output_path.exists() or output_path.stat().st_size == 0:
        raise RuntimeError("FFmpeg completed without producing a video.")
    return output_path
