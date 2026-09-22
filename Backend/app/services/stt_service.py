"""
STT Service — Speech-to-Text Conversion
Model: openai/whisper-large-v3 using transformers pipeline

Important note for backend:
The model is loaded only once (on first call) and stays in memory as a lazy singleton
with thread-safe locking. This way each request doesn't have to download/load
several gigabytes of model from HuggingFace again.

If you're running with multiple worker processes (e.g., gunicorn -w 4), each worker
loads the model separately once — this is normal, but means each worker's memory
must be sufficient for a whisper-large-v3 model (several gigabytes).
"""

import logging
import os
import threading

import librosa
import numpy as np
import pyloudnorm as pyln
import torch
from transformers import pipeline

logger = logging.getLogger(__name__)

# You can override these with environment variables without changing code
STT_MODEL_NAME = os.getenv("STT_MODEL_NAME", "openai/whisper-large-v3")
STT_LANGUAGE = os.getenv("STT_LANGUAGE", "fa")
STT_TARGET_SR = 16000

# Winning preprocessing config from the own-data comparison
# (stt_preprocessing_comparison_own_data.csv): loudness norm + trim, no denoise.
STT_TARGET_LUFS = -23.0
STT_TRIM_TOP_DB = 30

_asr_pipe = None
_lock = threading.Lock()


class STTError(Exception):
    """Error related to speech-to-text conversion stage."""


def _get_pipeline():
    global _asr_pipe
    if _asr_pipe is None:
        with _lock:
            if _asr_pipe is None:  # double-checked locking
                logger.info("Loading STT model: %s", STT_MODEL_NAME)
                device = 0 if torch.cuda.is_available() else -1
                dtype = torch.float16 if device >= 0 else torch.float32
                try:
                    _asr_pipe = pipeline(
                        "automatic-speech-recognition",
                        model=STT_MODEL_NAME,
                        device=device,
                        torch_dtype=dtype,
                        chunk_length_s=30,
                        generate_kwargs={"language": STT_LANGUAGE, "task": "transcribe"},
                    )
                except Exception as e:
                    logger.exception("Failed to load STT model")
                    raise STTError(f"STT model loading failed: {e}") from e
                logger.info("STT model loaded successfully on device=%s", device)
    return _asr_pipe


def _preprocess_for_stt(speech: "np.ndarray", sr: int) -> "np.ndarray":
    """Loudness-normalize and trim silence (best config on our own 112-sample set:
    WER 34.28% vs 35.33% for raw resample+mono only). No denoising — it didn't help.
    """
    try:
        meter = pyln.Meter(sr)
        loudness = meter.integrated_loudness(speech)
        if np.isfinite(loudness):
            speech = pyln.normalize.loudness(speech, loudness, STT_TARGET_LUFS)
    except Exception as e:
        logger.warning("Loudness normalization failed, continuing with raw audio: %s", e)

    max_val = np.max(np.abs(speech)) if speech.size else 0.0
    if max_val > 1.0:
        speech = speech / max_val * 0.98

    try:
        speech, _ = librosa.effects.trim(speech, top_db=STT_TRIM_TOP_DB)
    except Exception as e:
        logger.warning("Silence trimming failed, continuing untrimmed: %s", e)

    return speech


def transcribe_audio(file_path: str) -> str:
    """
    Input: audio file path
    Output: extracted text from speech
    """
    if not file_path or not os.path.exists(file_path):
        raise STTError(f"Audio file not found: {file_path}")

    asr_pipe = _get_pipeline()

    try:
        speech, _ = librosa.load(file_path, sr=STT_TARGET_SR, mono=True)
    except Exception as e:
        logger.exception("Error loading audio file: %s", file_path)
        raise STTError(f"Error reading audio file (unsupported format?): {e}") from e

    if speech.size == 0:
        raise STTError("Audio file is empty or unreadable.")

    speech = _preprocess_for_stt(speech, STT_TARGET_SR)

    if speech.size == 0:
        raise STTError("Audio file is empty or unreadable after trimming.")

    try:
        result = asr_pipe(speech)
        transcript = (result.get("text") or "").strip()
    except Exception as e:
        logger.exception("Error running STT model on file: %s", file_path)
        raise STTError(f"Error in speech-to-text conversion: {e}") from e

    return transcript