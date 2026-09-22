from app.workers.celery_app import celery_app
from app.db.session import SessionLocal
from app.db.models.voice_note import VoiceNote
from app.db.models.emotion_score import VoiceEmotionScore, TextEmotionScore
from app.services.voice_emotion_service import analyze_voice_emotion
from app.services.stt_service import transcribe_audio
from app.services.text_emotion_service import analyze_text_emotion
from app.services.text_correction_service import correct_transcript, TextCorrectionError
import logging

logger = logging.getLogger(__name__)


@celery_app.task(name="process_voice_note")
def process_voice_note(voice_note_id: str):
    db = SessionLocal()
    try:
        voice_note = db.query(VoiceNote).filter(VoiceNote.id == voice_note_id).first()
        if not voice_note:
            return

        voice_emotions = analyze_voice_emotion(voice_note.file_path)
        raw_transcript = transcribe_audio(voice_note.file_path)

        try:
            corrected_transcript = correct_transcript(raw_transcript)
        except TextCorrectionError:

            logger.warning("Text correction failed for %s, using raw transcript", voice_note_id)
            corrected_transcript = raw_transcript

        text_emotions = analyze_text_emotion(corrected_transcript)

        db.add(VoiceEmotionScore(voice_note_id=voice_note.id, **voice_emotions))
        db.add(TextEmotionScore(voice_note_id=voice_note.id, **text_emotions))

        voice_note.transcript_raw = raw_transcript
        voice_note.transcript = corrected_transcript
        voice_note.status = "done"
        db.commit()

    except Exception as e:
        voice_note.status = "failed"
        db.commit()
        raise e

    finally:
        db.close()