import uuid
from pathlib import Path
from fastapi import UploadFile
from app.core.config import settings
from mutagen import File as MutagenFile


def _save_file(file: UploadFile, subdirectory: str) -> str:
    storage_dir = Path(settings.audio_storage_path).parent / subdirectory
    storage_dir.mkdir(parents=True, exist_ok=True)

    extension = Path(file.filename).suffix or ""
    unique_filename = f"{uuid.uuid4()}{extension}"
    file_path = storage_dir / unique_filename

    with open(file_path, "wb") as buffer:
        buffer.write(file.file.read())

    return str(file_path)


def save_voice_file(file: UploadFile) -> str:
    return _save_file(file, "voice_notes")


def save_image_file(file: UploadFile) -> str:
    return _save_file(file, "images")



def get_audio_duration_seconds(file_path: str) -> float | None:
    try:
        audio = MutagenFile(file_path)
        if audio is None or audio.info is None:
            return None
        return round(audio.info.length, 2)
    except Exception:
        return None