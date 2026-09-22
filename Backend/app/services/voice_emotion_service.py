import logging
import os
import threading

import joblib
import librosa
import numpy as np
import torch
from transformers import Wav2Vec2FeatureExtractor, Wav2Vec2Model

logger = logging.getLogger(__name__)

AUDIO_ENCODER_PATH = os.getenv(
    "VOICE_EMOTION_ENCODER_PATH",
    "./ml_models/voice_emotion/phase1"
)

FINAL_CLASSIFIER_PATH = os.getenv(
    "VOICE_EMOTION_CLASSIFIER_PATH",
    "./ml_models/voice_emotion/phase2"
)

AUDIO_MODEL_LABEL_MAP = {
    "anger": "anger",
    "happiness": "happiness",
    "neutral": "neutral",
    "sadness": "sadness",
}
SUPPORTED_LABELS = sorted(AUDIO_MODEL_LABEL_MAP.values())

_encoder = None
_feature_extractor = None
_scaler = None
_classifier = None
_target_sr = None
_device = None
_lock = threading.Lock()


class VoiceEmotionError(Exception):
    """Error related to audio emotion analysis stage."""


def _get_models():
    global _encoder, _feature_extractor, _scaler, _classifier, _target_sr, _device
    if _encoder is None:
        with _lock:
            if _encoder is None:
                logger.info("Loading voice-emotion encoder from %s", AUDIO_ENCODER_PATH)
                _device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
                try:
                    _feature_extractor = Wav2Vec2FeatureExtractor.from_pretrained(AUDIO_ENCODER_PATH)
                    _encoder = Wav2Vec2Model.from_pretrained(AUDIO_ENCODER_PATH)
                    _encoder.eval()
                    _encoder.to(_device)
                    _target_sr = _feature_extractor.sampling_rate

                    scaler_path = os.path.join(FINAL_CLASSIFIER_PATH, "scaler.joblib")
                    clf_path = os.path.join(FINAL_CLASSIFIER_PATH, "logistic_classifier.joblib")
                    _scaler = joblib.load(scaler_path)
                    _classifier = joblib.load(clf_path)
                except Exception as e:
                    logger.exception("Failed to load voice-emotion models")
                    raise VoiceEmotionError(f"Voice emotion model loading failed: {e}") from e

                unmapped = sorted({c for c in _classifier.classes_ if c.lower() not in AUDIO_MODEL_LABEL_MAP})
                if unmapped:
                    logger.warning("Classifier classes that are not mapped: %s", unmapped)

                logger.info("Voice-emotion models loaded. Classes: %s", list(_classifier.classes_))
    return _encoder, _feature_extractor, _scaler, _classifier, _target_sr, _device


def _extract_prosodic_features(speech: np.ndarray, sr: int) -> np.ndarray:

    f0, _, _ = librosa.pyin(
        speech, fmin=librosa.note_to_hz("C2"), fmax=librosa.note_to_hz("C7"), sr=sr
    )
    f0_voiced = f0[~np.isnan(f0)]
    if len(f0_voiced) == 0:
        f0_mean, f0_std, f0_range = 0.0, 0.0, 0.0
    else:
        f0_mean, f0_std = float(np.mean(f0_voiced)), float(np.std(f0_voiced))
        f0_range = float(np.max(f0_voiced) - np.min(f0_voiced))

    rms = librosa.feature.rms(y=speech)[0]
    rms_mean, rms_std = float(np.mean(rms)), float(np.std(rms))
    zcr_mean = float(np.mean(librosa.feature.zero_crossing_rate(speech)[0]))
    centroid = librosa.feature.spectral_centroid(y=speech, sr=sr)[0]
    centroid_mean, centroid_std = float(np.mean(centroid)), float(np.std(centroid))

    return np.array([f0_mean, f0_std, f0_range, rms_mean, rms_std, zcr_mean, centroid_mean, centroid_std])


def analyze_voice_emotion(file_path: str) -> dict:

    if not file_path or not os.path.exists(file_path):
        raise VoiceEmotionError(f"Audio file not found: {file_path}")

    encoder, feature_extractor, scaler, classifier, target_sr, device = _get_models()

    try:
        speech, _ = librosa.load(file_path, sr=target_sr, mono=True)
    except Exception as e:
        logger.exception("Error loading audio file: %s", file_path)
        raise VoiceEmotionError(f"Error reading audio file (unsupported format?): {e}") from e

    if speech.size == 0:
        raise VoiceEmotionError("Audio file is empty or unreadable.")

    try:
        # Extract Wav2Vec2 embedding
        with torch.no_grad():
            inputs = feature_extractor(speech, sampling_rate=target_sr, return_tensors="pt", padding=True)
            input_values = inputs["input_values"].to(device)
            hidden_states = encoder(input_values).last_hidden_state
            embedding = hidden_states.mean(dim=1).squeeze(0).cpu().numpy()

        # Extract prosodic features
        prosody = _extract_prosodic_features(speech, target_sr)
        features = np.concatenate([embedding, prosody]).reshape(1, -1)
        features_scaled = scaler.transform(features)

        # Get prediction probabilities
        probs = classifier.predict_proba(features_scaled)[0]
        classes = classifier.classes_
    except Exception as e:
        logger.exception("Error running voice emotion model")
        raise VoiceEmotionError(f"Error in voice emotion analysis: {e}") from e

    # Map to unified labels
    result = {label: 0.0 for label in SUPPORTED_LABELS}
    for cls, prob in zip(classes, probs):
        unified = AUDIO_MODEL_LABEL_MAP.get(str(cls).lower())
        if unified:
            result[unified] += float(prob)

    return result