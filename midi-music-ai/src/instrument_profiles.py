from __future__ import annotations

from dataclasses import dataclass
from typing import Dict

import pretty_midi


@dataclass(frozen=True)
class InstrumentProfile:
    key: str
    display_name: str
    min_note: str
    max_note: str
    minimum_note_duration: float
    max_polyphony: int

    @property
    def min_pitch(self) -> int:
        return pretty_midi.note_name_to_number(self.min_note)

    @property
    def max_pitch(self) -> int:
        return pretty_midi.note_name_to_number(self.max_note)

    @property
    def monophonic(self) -> bool:
        return self.max_polyphony == 1


INSTRUMENT_PROFILES: Dict[str, InstrumentProfile] = {
    "geomungo": InstrumentProfile(
        key="geomungo",
        display_name="거문고",
        min_note="E3",
        max_note="F6",
        minimum_note_duration=0.08,
        max_polyphony=3,
    ),
    "haegeum": InstrumentProfile(
        key="haegeum",
        display_name="해금",
        min_note="A4",
        max_note="E7",
        minimum_note_duration=0.08,
        max_polyphony=1,
    ),
    "daegeum": InstrumentProfile(
        key="daegeum",
        display_name="대금",
        min_note="B4",
        max_note="G7",
        minimum_note_duration=0.10,
        max_polyphony=1,
    ),
    "gayageum": InstrumentProfile(
        key="gayageum",
        display_name="가야금",
        min_note="D3",
        max_note="G5",
        minimum_note_duration=0.06,
        max_polyphony=4,
    ),
    "piri": InstrumentProfile(
        key="piri",
        display_name="피리",
        min_note="B4",
        max_note="F6",
        minimum_note_duration=0.08,
        max_polyphony=1,
    ),
    "danso": InstrumentProfile(
        key="danso",
        display_name="단소",
        min_note="G4",
        max_note="G6",
        minimum_note_duration=0.10,
        max_polyphony=1,
    ),
}


def get_instrument_profile(instrument: str) -> InstrumentProfile:
    try:
        return INSTRUMENT_PROFILES[instrument]
    except KeyError as exc:
        supported = ", ".join(sorted(INSTRUMENT_PROFILES))
        raise ValueError(
            f"지원하지 않는 악기입니다: {instrument}. 지원 악기: {supported}"
        ) from exc

