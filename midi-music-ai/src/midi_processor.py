from __future__ import annotations

from pathlib import Path
from typing import Iterable, List, Tuple

import pretty_midi

from instrument_profiles import InstrumentProfile, get_instrument_profile


def choose_best_octave_shift(
    pitches: Iterable[int], min_pitch: int, max_pitch: int
) -> int:
    pitch_list = list(pitches)
    if not pitch_list:
        raise ValueError("음정 목록이 비어 있습니다.")

    center = (min_pitch + max_pitch) / 2

    def score(shift: int) -> Tuple[int, int, float]:
        shifted = [pitch + shift for pitch in pitch_list]
        in_range = sum(min_pitch <= pitch <= max_pitch for pitch in shifted)
        average_distance = sum(abs(pitch - center) for pitch in shifted) / len(shifted)
        # 같은 수의 음표가 음역에 들어온다면 원곡에서 가장 적게 이동한
        # 옥타브를 선택한다. 음역 중앙 정렬은 마지막 동률 조건으로만 쓴다.
        return in_range, -abs(shift), -average_distance

    return max(range(-60, 61, 12), key=score)


def fold_pitch_into_range(pitch: int, min_pitch: int, max_pitch: int) -> int:
    while pitch < min_pitch:
        pitch += 12
    while pitch > max_pitch:
        pitch -= 12
    return pitch


def merge_same_pitch_overlaps(notes: List[pretty_midi.Note]) -> List[pretty_midi.Note]:
    merged: List[pretty_midi.Note] = []
    for note in sorted(notes, key=lambda item: (item.pitch, item.start, item.end)):
        if merged and merged[-1].pitch == note.pitch and note.start < merged[-1].end:
            merged[-1].end = max(merged[-1].end, note.end)
            merged[-1].velocity = max(merged[-1].velocity, note.velocity)
        else:
            merged.append(note)
    return sorted(merged, key=lambda item: (item.start, item.pitch))


def limit_polyphony(
    notes: List[pretty_midi.Note], max_polyphony: int
) -> List[pretty_midi.Note]:
    if max_polyphony < 1:
        raise ValueError("max_polyphony는 1 이상이어야 합니다.")

    kept: List[pretty_midi.Note] = []
    for note in sorted(notes, key=lambda item: (item.start, -item.velocity, -item.end)):
        active = [item for item in kept if item.start <= note.start < item.end]
        if len(active) < max_polyphony:
            kept.append(note)
    return sorted(kept, key=lambda item: (item.start, item.pitch))


def make_monophonic(notes: List[pretty_midi.Note]) -> List[pretty_midi.Note]:
    selected: List[pretty_midi.Note] = []
    for note in sorted(notes, key=lambda item: (item.start, -item.velocity, -item.end)):
        if not selected:
            selected.append(note)
            continue

        previous = selected[-1]
        if note.start == previous.start:
            if (note.velocity, note.end) > (previous.velocity, previous.end):
                selected[-1] = note
            continue

        if note.start < previous.end:
            previous.end = note.start
        selected.append(note)
    return selected


def process_midi(
    input_midi: Path,
    output_midi: Path,
    instrument: str,
) -> Path:
    input_midi = input_midi.resolve()
    output_midi = output_midi.resolve()
    profile: InstrumentProfile = get_instrument_profile(instrument)

    if not input_midi.exists():
        raise FileNotFoundError(f"정제할 MIDI가 없습니다: {input_midi}")

    midi = pretty_midi.PrettyMIDI(str(input_midi))
    all_notes = [
        note
        for midi_instrument in midi.instruments
        if not midi_instrument.is_drum
        for note in midi_instrument.notes
    ]
    if not all_notes:
        raise RuntimeError(f"MIDI에 정제할 음표가 없습니다: {input_midi}")

    octave_shift = choose_best_octave_shift(
        (note.pitch for note in all_notes),
        profile.min_pitch,
        profile.max_pitch,
    )

    for note in all_notes:
        note.pitch = fold_pitch_into_range(
            note.pitch + octave_shift,
            profile.min_pitch,
            profile.max_pitch,
        )

    notes = [
        note
        for note in all_notes
        if note.end - note.start >= profile.minimum_note_duration
    ]
    notes = merge_same_pitch_overlaps(notes)
    notes = (
        make_monophonic(notes)
        if profile.monophonic
        else limit_polyphony(notes, profile.max_polyphony)
    )
    notes = [
        note
        for note in notes
        if note.end - note.start >= profile.minimum_note_duration
    ]
    if not notes:
        raise RuntimeError("정제 후 남은 MIDI 음표가 없습니다.")

    program = pretty_midi.instrument_name_to_program("Acoustic Grand Piano")
    processed_instrument = pretty_midi.Instrument(
        program=program,
        # 일부 mido 버전은 MIDI 트랙 이름을 Latin-1로 인코딩한다.
        name=profile.key,
    )
    processed_instrument.notes = notes
    midi.instruments = [processed_instrument]

    output_midi.parent.mkdir(parents=True, exist_ok=True)
    midi.write(str(output_midi))
    return output_midi
