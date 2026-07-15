import os

from app.models.base import ModelAdapter

_ADAPTER_CACHE: dict[str, ModelAdapter] = {}


def create_model_adapter(adapter_name: str | None = None) -> ModelAdapter:
    selected = (adapter_name or os.getenv("MODEL_ADAPTER") or "auto").lower()
    if selected == "auto":
        selected = "opencv_ink"

    if selected in _ADAPTER_CACHE:
        return _ADAPTER_CACHE[selected]

    if selected in {"opencv_ink", "opencv-ink", "ink_wash", "ink-wash", "sumukhwa"}:
        try:
            from app.models.opencv_ink import OpenCVInkWashAdapter
        except ModuleNotFoundError as exc:
            raise RuntimeError(
                "The Sumukhwa adapter file app/models/opencv_ink.py is missing. "
                "Commit this file before deploying MODEL_ADAPTER=auto or styleType=sumukhwa."
            ) from exc

        adapter = OpenCVInkWashAdapter()
        _ADAPTER_CACHE[selected] = adapter
        return adapter

    if selected in {"opencv_minhwa", "opencv-minhwa", "minhwa"}:
        try:
            from app.models.opencv_minhwa import OpenCVMinhwaAdapter
        except ModuleNotFoundError as exc:
            raise RuntimeError(
                "The Minhwa adapter file app/models/opencv_minhwa.py is missing. "
                "Commit this file before deploying MODEL_ADAPTER=auto or styleType=minhwa."
            ) from exc

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
