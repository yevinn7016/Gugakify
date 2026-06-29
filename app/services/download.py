from pathlib import Path
from urllib.parse import urlparse

import httpx


async def download_video(
    url: str,
    original_file_name: str,
    output_dir: Path,
    max_bytes: int,
) -> Path:
    output_dir.mkdir(parents=True, exist_ok=True)
    if _is_youtube_url(url):
        return await _download_youtube_video(url, output_dir, max_bytes)

    extension = _guess_extension(url, original_file_name)
    output_path = output_dir / f"input{extension}"

    downloaded = 0
    async with httpx.AsyncClient(timeout=httpx.Timeout(60.0, read=120.0)) as client:
        async with client.stream("GET", url, follow_redirects=True) as response:
            response.raise_for_status()

            content_type = response.headers.get("content-type", "")
            if content_type and not _looks_like_video(content_type):
                raise ValueError(f"URL does not look like a direct video file: {content_type}")

            with output_path.open("wb") as file:
                async for chunk in response.aiter_bytes():
                    downloaded += len(chunk)
                    if downloaded > max_bytes:
                        raise ValueError("Input video exceeds the configured max download size.")
                    file.write(chunk)

    if output_path.stat().st_size == 0:
        raise ValueError("Downloaded video is empty.")

    return output_path


async def _download_youtube_video(url: str, output_dir: Path, max_bytes: int) -> Path:
    try:
        import yt_dlp
    except ImportError as exc:
        raise RuntimeError("yt-dlp is required to download YouTube URLs.") from exc

    import asyncio

    def _download() -> Path:
        for stale_file in output_dir.glob("input.*"):
            if stale_file.is_file():
                stale_file.unlink()

        output_template = str(output_dir / "input.%(ext)s")
        options = {
            "format": (
                "18/"
                "best[ext=mp4][vcodec!=none][acodec!=none][height<=480]/"
                "best[vcodec!=none][acodec!=none][height<=480]/"
                "best[ext=mp4][vcodec!=none][acodec!=none]/"
                "best[vcodec!=none][acodec!=none]"
            ),
            "outtmpl": output_template,
            "noplaylist": True,
            "quiet": True,
            "no_warnings": True,
            "overwrites": True,
            "continuedl": False,
            "retries": 3,
            "fragment_retries": 3,
            "socket_timeout": 30,
            "merge_output_format": "mp4",
            "max_filesize": max_bytes,
        }
        try:
            with yt_dlp.YoutubeDL(options) as downloader:
                downloader.download([url])
        except yt_dlp.utils.DownloadError as exc:
            _remove_empty_downloads(output_dir)
            raise ValueError(f"YouTube download failed: {_clean_ytdlp_error(str(exc))}") from exc

        candidates = sorted(
            output_dir.glob("input.*"),
            key=lambda path: path.stat().st_mtime,
            reverse=True,
        )
        if not candidates:
            raise ValueError("YouTube download did not produce a video file.")

        output_path = candidates[0]
        if output_path.stat().st_size == 0:
            output_path.unlink(missing_ok=True)
            raise ValueError(
                "YouTube download produced an empty file. Try another video, "
                "a direct mp4 URL, or a YouTube URL that does not require cookies/login."
            )
        if output_path.stat().st_size > max_bytes:
            raise ValueError("Input video exceeds the configured max download size.")
        return output_path

    return await asyncio.to_thread(_download)


def _remove_empty_downloads(output_dir: Path) -> None:
    for path in output_dir.glob("input.*"):
        if path.is_file() and path.stat().st_size == 0:
            path.unlink(missing_ok=True)


def _clean_ytdlp_error(message: str) -> str:
    return message.replace("\x1b[0;31m", "").replace("\x1b[0m", "").strip()


def _guess_extension(url: str, original_file_name: str) -> str:
    candidates = [Path(original_file_name).suffix, Path(urlparse(url).path).suffix]
    for suffix in candidates:
        if suffix.lower() in {".mp4", ".mov", ".m4v", ".avi", ".webm", ".mkv"}:
            return suffix.lower()
    return ".mp4"


def _is_youtube_url(url: str) -> bool:
    host = urlparse(url).netloc.lower()
    return host in {"youtu.be", "www.youtu.be"} or host.endswith("youtube.com")


def _looks_like_video(content_type: str) -> bool:
    normalized = content_type.split(";")[0].strip().lower()
    return normalized.startswith("video/") or normalized in {
        "application/octet-stream",
        "binary/octet-stream",
    }
