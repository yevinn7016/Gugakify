from __future__ import annotations

import json
import math
import wave
from pathlib import Path

from analyzer import analyze_audio
from director import build_direction
from renderer import _ink_texture_mask, render_video


def _write_tone(path: Path, duration: float = 1.2, sample_rate: int = 22_050) -> None:
    frames = bytearray()
    for index in range(int(duration * sample_rate)):
        time = index / sample_rate
        pulse = 1.0 if int(time * 4) % 2 == 0 else 0.25
        sample = int(12_000 * pulse * math.sin(2 * math.pi * 220 * time))
        frames.extend(sample.to_bytes(2, byteorder="little", signed=True))
    with wave.open(str(path), "wb") as output:
        output.setnchannels(1)
        output.setsampwidth(2)
        output.setframerate(sample_rate)
        output.writeframes(frames)


def test_analysis_and_direction_are_json_serializable(tmp_path: Path) -> None:
    audio = tmp_path / "tone.wav"
    _write_tone(audio)
    analysis = analyze_audio(audio)
    direction = build_direction(analysis, mood="calm", jangdan="jungmori")

    assert 0 < analysis["duration"] <= 30
    assert analysis["samples"]
    assert direction["mood"] == "calm"
    assert direction["jangdan"] == "jungmori"
    assert all(0 <= scene["energy"] <= 1 for scene in direction["scenes"])
    json.dumps({"analysis": analysis, "direction": direction})


def test_renderer_streams_frames_to_mp4(tmp_path: Path) -> None:
    audio = tmp_path / "tone.wav"
    output = tmp_path / "result.mp4"
    _write_tone(audio)
    analysis = analyze_audio(audio)
    direction = build_direction(analysis)
    direction["render"].update({"width": 160, "height": 90, "fps": 8, "duration": 1.0})

    render_video(audio, output, analysis, direction)

    assert output.exists()
    assert output.stat().st_size > 1_000


def test_packaged_petal_assets_have_transparency() -> None:
    from PIL import Image

    assets = sorted((Path(__file__).resolve().parents[1] / "assets" / "petals").glob("petal-??.png"))
    assert len(assets) == 6
    for asset in assets:
        with Image.open(asset) as image:
            assert image.mode == "RGBA"
            assert image.getchannel("A").getextrema() == (0, 255)


def test_packaged_background_set_is_complete() -> None:
    background_dir = Path(__file__).resolve().parents[1] / "assets" / "backgrounds"
    assert {path.name for path in background_dir.glob("*.png")} == {
        "ink-moon-mountains.png",
        "ink-mountain-river.png",
        "ink-waterfall-valley.png",
    }


def test_packaged_ink_assets_have_transparency() -> None:
    from PIL import Image

    ink_dir = Path(__file__).resolve().parents[1] / "assets" / "ink"
    assets = [ink_dir / name for name in ("ink-burst.png", "ink-wash.png", "ink-circle.png", "ink-sweep.png")]
    assert all(path.exists() for path in assets)
    for asset in assets:
        with Image.open(asset) as image:
            assert image.mode == "RGBA"
            assert image.getchannel("A").getextrema() == (0, 255)


def test_brush_and_fog_assets_have_transparency() -> None:
    from PIL import Image

    root = Path(__file__).resolve().parents[1] / "assets"
    assets = list((root / "brushes").glob("brush-*.png")) + list((root / "fog").glob("fog-*.png"))
    final_assets = [path for path in assets if "sheet" not in path.name]
    assert len(final_assets) == 9
    for asset in final_assets:
        with Image.open(asset) as image:
            assert image.mode == "RGBA"
            assert image.getchannel("A").getextrema() == (0, 255)


def test_overlay_brush_mask_preserves_full_asset() -> None:
    brush = Path(__file__).resolve().parents[1] / "assets" / "brushes" / "brush-circle.png"
    mask = _ink_texture_mask(str(brush), (320, 180), crop_to_fill=False)
    bbox = mask.getbbox()
    assert bbox is not None
    assert bbox[0] > 0 and bbox[2] < mask.width
