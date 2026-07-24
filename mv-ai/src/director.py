from __future__ import annotations

from typing import Any


JANGDAN_BY_TEMPO = (
    (70, "jinyangjo"),
    (110, "jungmori"),
    (150, "jajinmori"),
    (float("inf"), "hwimori"),
)


def infer_jangdan(bpm: float) -> str:
    return next(name for limit, name in JANGDAN_BY_TEMPO if bpm < limit)


def infer_mood(analysis: dict[str, Any]) -> str:
    bpm = float(analysis["bpm"])
    energy = float(analysis["summary"]["energy"])
    high = float(analysis["summary"]["highBand"])
    if bpm >= 120 and energy >= 0.48:
        return "energetic"
    if bpm < 90 and energy < 0.45:
        return "calm"
    if high >= 0.58:
        return "bright"
    return "balanced"


def build_direction(
    analysis: dict[str, Any],
    mood: str | None = None,
    jangdan: str | None = None,
) -> dict[str, Any]:
    selected_mood = mood or infer_mood(analysis)
    selected_jangdan = jangdan or infer_jangdan(float(analysis["bpm"]))
    scenes = []
    palettes = {
        "calm": ["moon_mountain", "mist_river", "bamboo_dawn"],
        "energetic": ["palace_festival", "red_sunset", "storm_mountain"],
        "bright": ["spring_palace", "lotus_lake", "bamboo_dawn"],
        "balanced": ["mist_river", "moon_mountain", "spring_palace"],
    }
    choices = palettes.get(selected_mood, palettes["balanced"])
    for index, section in enumerate(analysis["sections"]):
        section_samples = [
            sample
            for sample in analysis["samples"]
            if float(section["start"]) <= float(sample["time"]) < float(section["end"])
        ]
        section_energy = (
            sum(float(sample["energy"]) for sample in section_samples) / len(section_samples)
            if section_samples
            else float(analysis["summary"]["energy"])
        )
        scenes.append({
            "index": index,
            "start": section["start"],
            "end": section["end"],
            "background": choices[index % len(choices)],
            "transition": "ink" if index % 2 else "brush",
            "energy": round(section_energy, 4),
        })

    ink_events = [
        event for event in analysis["onsets"] if float(event["strength"]) >= 0.65
    ]
    return {
        "mood": selected_mood,
        "jangdan": selected_jangdan,
        "scenes": scenes,
        "inkEvents": ink_events,
        "render": {
            "width": 1280,
            "height": 720,
            "fps": 24,
            "duration": analysis["duration"],
        },
        "backgroundPrompt": (
            "traditional Korean ink wash painting, hanji paper texture, "
            f"{selected_mood} atmosphere, wide cinematic composition, "
            "muted traditional color accents, no text, no people"
        ),
    }
