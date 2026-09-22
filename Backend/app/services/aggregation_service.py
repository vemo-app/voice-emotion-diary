from collections import defaultdict
from datetime import date, timedelta
from zoneinfo import ZoneInfo

from sqlalchemy.orm import Session

from app.db.models.voice_note import VoiceNote
from app.db.models.emotion_score import VoiceEmotionScore, TextEmotionScore
from app.services.jalali_utils import jalali_month_range, to_jalali

EMOTIONS = ["anger", "happiness", "sadness", "neutral"]
LOCAL_TZ = ZoneInfo("Asia/Tehran")


def get_week_start(for_date: date) -> date:
    days_since_saturday = (for_date.weekday() - 5) % 7
    return for_date - timedelta(days=days_since_saturday)


def _fetch_scored_notes(db: Session, user_id, range_start: date, range_end: date):
    return (
        db.query(VoiceNote, VoiceEmotionScore, TextEmotionScore)
        .join(VoiceEmotionScore, VoiceEmotionScore.voice_note_id == VoiceNote.id)
        .join(TextEmotionScore, TextEmotionScore.voice_note_id == VoiceNote.id)
        .filter(
            VoiceNote.user_id == user_id,
            VoiceNote.status == "done",
            VoiceNote.recorded_at >= range_start,
            VoiceNote.recorded_at < range_end + timedelta(days=1),
        )
        .all()
    )


def _average_combined(rows, keep_fn) -> dict:
    totals = {emotion: 0.0 for emotion in EMOTIONS}
    count = 0
    for voice_note, voice_score, text_score in rows:
        local_dt = voice_note.recorded_at.astimezone(LOCAL_TZ)
        if not keep_fn(local_dt):
            continue
        for emotion in EMOTIONS:
            totals[emotion] += (getattr(voice_score, emotion) + getattr(text_score, emotion)) / 2
        count += 1

    if count == 0:
        return {**{emotion: 0.0 for emotion in EMOTIONS}, "notes_count": 0}
    return {**{emotion: totals[emotion] / count for emotion in EMOTIONS}, "notes_count": count}


def get_daily_report(db: Session, user_id, target_date: date) -> dict:
    rows = _fetch_scored_notes(db, user_id, target_date - timedelta(days=1), target_date + timedelta(days=1))
    return _average_combined(rows, keep_fn=lambda dt: dt.date() == target_date)


def get_weekly_report(db: Session, user_id, week_start: date) -> list[dict]:
    week_end = week_start + timedelta(days=6)
    rows = _fetch_scored_notes(db, user_id, week_start, week_end)

    daily_totals = defaultdict(lambda: {emotion: 0.0 for emotion in EMOTIONS})
    daily_counts = defaultdict(int)

    for voice_note, voice_score, text_score in rows:
        local_day = voice_note.recorded_at.astimezone(LOCAL_TZ).date()
        for emotion in EMOTIONS:
            daily_totals[local_day][emotion] += (getattr(voice_score, emotion) + getattr(text_score, emotion)) / 2
        daily_counts[local_day] += 1

    result = []
    for i in range(7):
        day = week_start + timedelta(days=i)
        count = daily_counts.get(day, 0)
        values = {emotion: 0.0 for emotion in EMOTIONS} if count == 0 else {
            emotion: daily_totals[day][emotion] / count for emotion in EMOTIONS
        }
        j = to_jalali(day)
        result.append({
            "date": day,
            "jalali_date": f"{j.year}-{j.month:02d}-{j.day:02d}",
            "notes_count": count,
            **values,
        })

    return result


def get_monthly_report(db: Session, user_id, jalali_year: int, jalali_month: int) -> dict:
    start_greg, end_greg = jalali_month_range(jalali_year, jalali_month)
    rows = _fetch_scored_notes(db, user_id, start_greg - timedelta(days=1), end_greg + timedelta(days=1))
    return _average_combined(rows, keep_fn=lambda dt: start_greg <= dt.date() <= end_greg)


def get_monthly_days_report(db: Session, user_id, jalali_year: int, jalali_month: int) -> list[dict]:
    start_greg, end_greg = jalali_month_range(jalali_year, jalali_month)
    rows = _fetch_scored_notes(db, user_id, start_greg - timedelta(days=1), end_greg + timedelta(days=1))

    daily_totals = defaultdict(lambda: {emotion: 0.0 for emotion in EMOTIONS})
    daily_counts = defaultdict(int)

    for voice_note, voice_score, text_score in rows:
        local_day = voice_note.recorded_at.astimezone(LOCAL_TZ).date()
        if not (start_greg <= local_day <= end_greg):
            continue
        for emotion in EMOTIONS:
            daily_totals[local_day][emotion] += (getattr(voice_score, emotion) + getattr(text_score, emotion)) / 2
        daily_counts[local_day] += 1

    result = []
    day = start_greg
    while day <= end_greg:
        count = daily_counts.get(day, 0)
        values = {emotion: 0.0 for emotion in EMOTIONS} if count == 0 else {
            emotion: daily_totals[day][emotion] / count for emotion in EMOTIONS
        }
        result.append({"date": day, "notes_count": count, **values})
        day += timedelta(days=1)

    return result

def get_week_summary(db: Session, user_id, week_start: date) -> dict:
    week_end = week_start + timedelta(days=6)
    rows = _fetch_scored_notes(db, user_id, week_start, week_end)
    return _average_combined(rows, keep_fn=lambda dt: week_start <= dt.date() <= week_end)


def get_weekly_trend(db: Session, user_id, anchor_date: date, weeks: int) -> list[dict]:
    anchor_week_start = get_week_start(anchor_date)
    result = []
    for i in range(weeks):
        week_start = anchor_week_start - timedelta(days=7 * (weeks - 1 - i))
        summary = get_week_summary(db, user_id, week_start)
        result.append({"week_start": week_start, "week_end": week_start + timedelta(days=6), **summary})
    return result

def get_profile_summary(db: Session, user_id) -> dict:
    total_notes = db.query(VoiceNote).filter(VoiceNote.user_id == user_id).count()

    rows = (
        db.query(VoiceNote, VoiceEmotionScore, TextEmotionScore)
        .join(VoiceEmotionScore, VoiceEmotionScore.voice_note_id == VoiceNote.id)
        .join(TextEmotionScore, TextEmotionScore.voice_note_id == VoiceNote.id)
        .filter(VoiceNote.user_id == user_id, VoiceNote.status == "done")
        .all()
    )
    emotion_distribution = _average_combined(rows, keep_fn=lambda dt: True)

    return {"total_notes": total_notes, **emotion_distribution}