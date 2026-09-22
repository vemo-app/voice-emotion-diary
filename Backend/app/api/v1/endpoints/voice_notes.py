import mimetypes
import uuid
from datetime import date, datetime, time, timedelta
from pathlib import Path
from typing import Annotated
from zoneinfo import ZoneInfo

from pydantic import BeforeValidator
from fastapi import APIRouter, Depends, UploadFile, File, Form, HTTPException, Query
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.db.models.voice_note import VoiceNote
from app.db.models.emotion_score import VoiceEmotionScore, TextEmotionScore
from app.db.models.user import User
from app.schemas.voice_note import VoiceNoteResponse
from app.services.storage_service import save_voice_file, save_image_file, get_audio_duration_seconds
from app.api.v1.deps import get_current_user
from app.workers.tasks import process_voice_note

from app.services.feedback_service import generate_empathetic_feedback, FeedbackError
from fastapi import Header
from app.core.language import resolve_response_language

router = APIRouter(prefix="/voice-notes", tags=["voice-notes"])

LOCAL_TZ = ZoneInfo("Asia/Tehran")
EMOTIONS = ["anger", "happiness", "sadness", "neutral"]


def _blank_to_none(value):
    if isinstance(value, str) and value == "":
        return None
    return value


OptionalImage = Annotated[UploadFile | None, File(), BeforeValidator(_blank_to_none)]


def _combined_emotion(voice_score, text_score) -> dict | None:
    if voice_score is None or text_score is None:
        return None
    return {e: (getattr(voice_score, e) + getattr(text_score, e)) / 2 for e in EMOTIONS}


def _to_response(voice_note: VoiceNote, voice_score=None, text_score=None) -> VoiceNoteResponse:
    return VoiceNoteResponse(
        id=voice_note.id,
        user_id=voice_note.user_id,
        title=voice_note.title,
        note=voice_note.note,
        has_image=voice_note.image_path is not None,
        status=voice_note.status,
        recorded_at=voice_note.recorded_at,
        transcript=voice_note.transcript,
        transcript_raw=voice_note.transcript_raw,
        emotion=_combined_emotion(voice_score, text_score),
        feedback=voice_note.feedback,
        duration_seconds=voice_note.duration_seconds,
    )

def _day_range_utc(local_day: date) -> tuple[datetime, datetime]:
    start = datetime.combine(local_day, time.min, tzinfo=LOCAL_TZ)
    end = datetime.combine(local_day + timedelta(days=1), time.min, tzinfo=LOCAL_TZ)
    return start.astimezone(ZoneInfo("UTC")), end.astimezone(ZoneInfo("UTC"))


@router.post("", response_model=VoiceNoteResponse)
def create_voice_note(
    file: Annotated[UploadFile, File()],
    title: Annotated[str, Form(min_length=1)],
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[Session, Depends(get_db)],
    note: Annotated[str | None, Form()] = None,
    image: OptionalImage = None,
):
    file_path = save_voice_file(file)
    duration_seconds = get_audio_duration_seconds(file_path)
    real_image = image if (image is not None and image.filename) else None
    image_path = save_image_file(real_image) if real_image is not None else None
    clean_note = note.strip() if note and note.strip() else None

    voice_note = VoiceNote(
        user_id=current_user.id,
        file_path=file_path,
        title=title.strip(),
        note=clean_note,
        image_path=image_path,
        duration_seconds=duration_seconds,
        status="processing",
    )
    db.add(voice_note)
    db.commit()
    db.refresh(voice_note)

    process_voice_note.delay(str(voice_note.id))
    return _to_response(voice_note)


@router.get("", response_model=list[VoiceNoteResponse])
def list_voice_notes(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[Session, Depends(get_db)],
    for_date: date | None = Query(default=None, description="Filter by a specific day; empty = all"),
):
    query = (
        db.query(VoiceNote, VoiceEmotionScore, TextEmotionScore)
        .outerjoin(VoiceEmotionScore, VoiceEmotionScore.voice_note_id == VoiceNote.id)
        .outerjoin(TextEmotionScore, TextEmotionScore.voice_note_id == VoiceNote.id)
        .filter(VoiceNote.user_id == current_user.id)
    )

    if for_date is not None:
        start_utc, end_utc = _day_range_utc(for_date)
        query = query.filter(VoiceNote.recorded_at >= start_utc, VoiceNote.recorded_at < end_utc)

    rows = query.order_by(VoiceNote.recorded_at.desc()).all()
    return [_to_response(vn, vs, ts) for vn, vs, ts in rows]


@router.get("/{voice_note_id}", response_model=VoiceNoteResponse)
def get_voice_note(
    voice_note_id: uuid.UUID,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[Session, Depends(get_db)],
):
    row = (
        db.query(VoiceNote, VoiceEmotionScore, TextEmotionScore)
        .outerjoin(VoiceEmotionScore, VoiceEmotionScore.voice_note_id == VoiceNote.id)
        .outerjoin(TextEmotionScore, TextEmotionScore.voice_note_id == VoiceNote.id)
        .filter(VoiceNote.id == voice_note_id, VoiceNote.user_id == current_user.id)
        .first()
    )
    if not row:
        raise HTTPException(status_code=404, detail="Voice note not found")
    voice_note, voice_score, text_score = row
    return _to_response(voice_note, voice_score, text_score)


@router.delete("/{voice_note_id}", status_code=204)
def delete_voice_note(
    voice_note_id: uuid.UUID,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[Session, Depends(get_db)],
):
    voice_note = (
        db.query(VoiceNote)
        .filter(VoiceNote.id == voice_note_id, VoiceNote.user_id == current_user.id)
        .first()
    )
    if not voice_note:
        raise HTTPException(status_code=404, detail="Voice note not found")

    db.query(VoiceEmotionScore).filter(VoiceEmotionScore.voice_note_id == voice_note.id).delete()
    db.query(TextEmotionScore).filter(TextEmotionScore.voice_note_id == voice_note.id).delete()

    for path_str in (voice_note.file_path, voice_note.image_path):
        if path_str:
            try:
                Path(path_str).unlink(missing_ok=True)
            except OSError:
                pass

    db.delete(voice_note)
    db.commit()
    return None


@router.get("/{voice_note_id}/download")
def download_voice_note(
    voice_note_id: uuid.UUID,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[Session, Depends(get_db)],
):
    voice_note = (
        db.query(VoiceNote)
        .filter(VoiceNote.id == voice_note_id, VoiceNote.user_id == current_user.id)
        .first()
    )
    if not voice_note:
        raise HTTPException(status_code=404, detail="Voice note not found")
    if not Path(voice_note.file_path).exists():
        raise HTTPException(status_code=404, detail="Audio file not found on server")

    extension = Path(voice_note.file_path).suffix
    media_type, _ = mimetypes.guess_type(voice_note.file_path)
    safe_title = "".join(c for c in voice_note.title if c.isalnum() or c in " _-").strip() or "voice-note"

    return FileResponse(path=voice_note.file_path, filename=f"{safe_title}{extension}", media_type=media_type or "application/octet-stream")


@router.post("/{voice_note_id}/feedback", response_model=VoiceNoteResponse)
def get_companion_feedback(
    voice_note_id: uuid.UUID,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[Session, Depends(get_db)],
    accept_language: str | None = Header(default=None, alias="Accept-Language"),
):
    row = (
        db.query(VoiceNote, VoiceEmotionScore, TextEmotionScore)
        .outerjoin(VoiceEmotionScore, VoiceEmotionScore.voice_note_id == VoiceNote.id)
        .outerjoin(TextEmotionScore, TextEmotionScore.voice_note_id == VoiceNote.id)
        .filter(VoiceNote.id == voice_note_id, VoiceNote.user_id == current_user.id)
        .first()
    )
    if not row:
        raise HTTPException(status_code=404, detail="Voice note not found")

    voice_note, voice_score, text_score = row
    if voice_note.status != "done":
        raise HTTPException(status_code=409, detail="This memory is not yet finished processing.")

    target_language = resolve_response_language(current_user.language, accept_language)

    if voice_note.feedback and voice_note.feedback_language == target_language:
        return _to_response(voice_note, voice_score, text_score)

    voice_emotion_dict = {e: getattr(voice_score, e) for e in EMOTIONS}
    text_emotion_dict = {e: getattr(text_score, e) for e in EMOTIONS}

    try:
        feedback_text = generate_empathetic_feedback(
            transcript=voice_note.transcript or "",
            voice_emotion=voice_emotion_dict,
            text_emotion=text_emotion_dict,
            language=target_language,
        )
    except FeedbackError as e:
        raise HTTPException(status_code=502, detail=str(e))

    voice_note.feedback = feedback_text
    voice_note.feedback_language = target_language
    db.commit()
    db.refresh(voice_note)

    return _to_response(voice_note, voice_score, text_score)

@router.patch("/{voice_note_id}", response_model=VoiceNoteResponse)
def update_voice_note(
    voice_note_id: uuid.UUID,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[Session, Depends(get_db)],
    title: Annotated[str | None, Form()] = None,
    note: Annotated[str | None, Form()] = None,
    remove_image: Annotated[bool, Form()] = False,
    image: OptionalImage = None,
):
    row = (
        db.query(VoiceNote, VoiceEmotionScore, TextEmotionScore)
        .outerjoin(VoiceEmotionScore, VoiceEmotionScore.voice_note_id == VoiceNote.id)
        .outerjoin(TextEmotionScore, TextEmotionScore.voice_note_id == VoiceNote.id)
        .filter(VoiceNote.id == voice_note_id, VoiceNote.user_id == current_user.id)
        .first()
    )
    if not row:
        raise HTTPException(status_code=404, detail="Voice note not found")
    voice_note, voice_score, text_score = row

    if title is not None:
        clean_title = title.strip()
        if not clean_title:
            raise HTTPException(status_code=422, detail="Title cannot be empty.")
        voice_note.title = clean_title

    if note is not None:
        voice_note.note = note.strip() or None

    real_image = image if (image is not None and image.filename) else None
    if real_image is not None:
        # Delete the previous image (if any) from the disk, then replace it.
        if voice_note.image_path:
            Path(voice_note.image_path).unlink(missing_ok=True)
        voice_note.image_path = save_image_file(real_image)
    elif remove_image and voice_note.image_path:
        Path(voice_note.image_path).unlink(missing_ok=True)
        voice_note.image_path = None

    db.commit()
    db.refresh(voice_note)
    return _to_response(voice_note, voice_score, text_score)


@router.get("/{voice_note_id}/image")
def get_voice_note_image(
    voice_note_id: uuid.UUID,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[Session, Depends(get_db)],
):
    voice_note = (
        db.query(VoiceNote)
        .filter(VoiceNote.id == voice_note_id, VoiceNote.user_id == current_user.id)
        .first()
    )
    if not voice_note or not voice_note.image_path:
        raise HTTPException(status_code=404, detail="No image has been recorded for this memory.")
    if not Path(voice_note.image_path).exists():
        raise HTTPException(status_code=404, detail="Image file not found on server.")

    media_type, _ = mimetypes.guess_type(voice_note.image_path)
    return FileResponse(path=voice_note.image_path, media_type=media_type or "image/jpeg")
