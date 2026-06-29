import os
from pathlib import Path

from app.models.base import ModelAdapter
from app.models.cyclegan import CycleGanStyleTransferAdapter
from app.models.dcgan import DcGanImageGeneratorAdapter


def create_model_adapter(adapter_name: str | None = None) -> ModelAdapter:
    selected = (adapter_name or os.getenv("MODEL_ADAPTER") or "cyclegan").lower()

    if selected == "cyclegan":
        checkpoint = _optional_path("CYCLEGAN_CHECKPOINT_PATH")
        return CycleGanStyleTransferAdapter(checkpoint_path=checkpoint)

    if selected == "dcgan":
        checkpoint = _optional_path("DCGAN_CHECKPOINT_PATH")
        return DcGanImageGeneratorAdapter(checkpoint_path=checkpoint)

    raise ValueError(f"Unsupported model adapter: {selected}")


def _optional_path(env_name: str) -> Path | None:
    value = os.getenv(env_name)
    return Path(value) if value else None
