import os
from pathlib import Path

from app.models.base import ModelAdapter
from app.models.cyclegan import CycleGanStyleTransferAdapter
from app.models.dcgan import DcGanImageGeneratorAdapter
from app.models.hf_sumukhwa import HuggingFaceSumukhwaImg2ImgAdapter
from app.models.opencv_ink import OpenCVInkWashAdapter
from app.models.opencv_minhwa import OpenCVMinhwaAdapter
from app.models.openai_image import OpenAIImageStyleTransferAdapter

_ADAPTER_CACHE: dict[str, ModelAdapter] = {}


def create_model_adapter(adapter_name: str | None = None) -> ModelAdapter:
    selected = (adapter_name or os.getenv("MODEL_ADAPTER") or "cyclegan").lower()
    if selected in _ADAPTER_CACHE:
        return _ADAPTER_CACHE[selected]

    if selected == "cyclegan":
        checkpoint = _optional_path("CYCLEGAN_CHECKPOINT_PATH")
        adapter = CycleGanStyleTransferAdapter(checkpoint_path=checkpoint)
        _ADAPTER_CACHE[selected] = adapter
        return adapter

    if selected == "dcgan":
        checkpoint = _optional_path("DCGAN_CHECKPOINT_PATH")
        adapter = DcGanImageGeneratorAdapter(checkpoint_path=checkpoint)
        _ADAPTER_CACHE[selected] = adapter
        return adapter

    if selected in {"openai", "openai_image", "openai-image"}:
        adapter = OpenAIImageStyleTransferAdapter()
        _ADAPTER_CACHE[selected] = adapter
        return adapter

    if selected in {"hf_sumukhwa", "huggingface_sumukhwa", "sumukhwa"}:
        adapter = HuggingFaceSumukhwaImg2ImgAdapter()
        _ADAPTER_CACHE[selected] = adapter
        return adapter

    if selected in {"opencv_ink", "opencv-ink", "ink_wash", "ink-wash"}:
        adapter = OpenCVInkWashAdapter()
        _ADAPTER_CACHE[selected] = adapter
        return adapter

    if selected in {"opencv_minhwa", "opencv-minhwa", "minhwa"}:
        adapter = OpenCVMinhwaAdapter()
        _ADAPTER_CACHE[selected] = adapter
        return adapter

    raise ValueError(f"Unsupported model adapter: {selected}")


def preload_model_adapter(adapter_name: str | None = None) -> ModelAdapter:
    adapter = create_model_adapter(adapter_name)
    load = getattr(adapter, "load", None)
    if callable(load):
        load()
    return adapter


def _optional_path(env_name: str) -> Path | None:
    value = os.getenv(env_name)
    return Path(value) if value else None
