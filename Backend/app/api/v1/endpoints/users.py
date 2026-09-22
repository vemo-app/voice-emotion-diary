import uuid
from pathlib import Path
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.db.models.user import User
from app.db.models.voice_note import VoiceNote
from app.db.models.emotion_score import VoiceEmotionScore, TextEmotionScore
from app.db.models.weekly_insight import WeeklyInsight
from app.db.models.monthly_insight import MonthlyInsight
from app.schemas.user import UserResponse, UserUpdate, ChangePasswordRequest, ProfileSummaryResponse
from app.api.v1.deps import get_current_user
from app.core.security import verify_password, hash_password
from app.services.aggregation_service import get_profile_summary
from app.services.jalali_utils import joined_month_label

router = APIRouter(prefix="/users", tags=["users"])


def _to_user_response(user: User) -> UserResponse:
    return UserResponse(
        id=user.id,
        username=user.username,
        email=user.email,
        created_at=user.created_at,
        joined_month_label=joined_month_label(user.created_at.date()),
        theme = user.theme,
        language = user.language,
    )


@router.get("/me", response_model=UserResponse)
def get_me(current_user: Annotated[User, Depends(get_current_user)]):
    return _to_user_response(current_user)


@router.get("/me/summary", response_model=ProfileSummaryResponse)
def get_my_summary(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[Session, Depends(get_db)],
):
    summary = get_profile_summary(db, current_user.id)
    return ProfileSummaryResponse(
        total_notes=summary["total_notes"],
        scored_notes_count=summary["notes_count"],
        anger=summary["anger"],
        happiness=summary["happiness"],
        sadness=summary["sadness"],
        neutral=summary["neutral"],
    )


@router.patch("/me", response_model=UserResponse)
def update_me(
    payload: UserUpdate,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[Session, Depends(get_db)],
):
    if payload.email is not None and payload.email != current_user.email:
        if db.query(User).filter(User.email == payload.email).first():
            raise HTTPException(status_code=400, detail="This email has already been used.")
        current_user.email = payload.email

    if payload.username is not None:
        clean_username = payload.username.strip()
        if not clean_username:
            raise HTTPException(status_code=422, detail="Name cannot be empty.")
        current_user.username = clean_username

    if payload.theme is not None:
        current_user.theme = payload.theme

    if payload.language is not None:
        current_user.language = payload.language

    db.commit()
    db.refresh(current_user)
    return _to_user_response(current_user)


@router.post("/me/change-password", status_code=204)
def change_password(
    payload: ChangePasswordRequest,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[Session, Depends(get_db)],
):
    if not verify_password(payload.current_password, current_user.password_hash):
        raise HTTPException(status_code=401, detail="The current password is incorrect.")

    if len(payload.new_password) < 6:
        raise HTTPException(status_code=422, detail="The new password must be at least 6 characters long.")

    current_user.password_hash = hash_password(payload.new_password)
    db.commit()
    return None


@router.delete("/me", status_code=204)
def delete_my_account(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[Session, Depends(get_db)],
):
    voice_notes = db.query(VoiceNote).filter(VoiceNote.user_id == current_user.id).all()
    voice_note_ids = [vn.id for vn in voice_notes]

    if voice_note_ids:
        db.query(VoiceEmotionScore).filter(
            VoiceEmotionScore.voice_note_id.in_(voice_note_ids)
        ).delete(synchronize_session=False)
        db.query(TextEmotionScore).filter(
            TextEmotionScore.voice_note_id.in_(voice_note_ids)
        ).delete(synchronize_session=False)

    for vn in voice_notes:
        for path_str in (vn.file_path, vn.image_path):
            if path_str:
                try:
                    Path(path_str).unlink(missing_ok=True)
                except OSError:
                    pass

    db.query(VoiceNote).filter(VoiceNote.user_id == current_user.id).delete(synchronize_session=False)
    db.query(WeeklyInsight).filter(WeeklyInsight.user_id == current_user.id).delete(synchronize_session=False)
    db.query(MonthlyInsight).filter(MonthlyInsight.user_id == current_user.id).delete(synchronize_session=False)

    db.delete(current_user)
    db.commit()
    return None