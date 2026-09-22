import json
import logging
import os
import threading

import torch
from huggingface_hub import hf_hub_download
from transformers import AutoModelForSequenceClassification, AutoTokenizer

logger = logging.getLogger(__name__)

TEXT_EMOTION_MODEL_PATH = os.getenv(
    "TEXT_EMOTION_MODEL_PATH",
    "/models/emotion_xlm_roberta_final",
)


_raw_override = os.getenv("TEXT_EMOTION_LABEL_OVERRIDE", "")
MANUAL_ID2LABEL_OVERRIDE = json.loads(_raw_override) if _raw_override else {}

UNIFIED_LABELS = ["anger", "happiness", "sadness", "neutral"]

TEXT_MODEL_LABEL_MAP = {
    "ANGRY": "anger",
    "HAPPY": "happiness",
    "HAPPINESS": "happiness",
    "SAD": "sadness",
    "SADNESS": "sadness",
    "NEUTRAL": "neutral",
    "HATE": "anger",
    "FEAR": "sadness",
    "SURPRISE": "neutral",
    "OTHER": "neutral",
}

_model = None
_tokenizer = None
_id2label = None
_device = None
_lock = threading.Lock()


class TextEmotionError(Exception):
    """Error related to text emotion analysis stage."""


def _load_id2label(model) -> dict:
    try:
        label_map_path = hf_hub_download(repo_id=TEXT_EMOTION_MODEL_PATH, filename="label_map.json")
        with open(label_map_path, "r", encoding="utf-8") as f:
            label_map = json.load(f)
        id2label = {int(k): v for k, v in label_map["id2label"].items()}
    except Exception:
        id2label = {int(k): v for k, v in model.config.id2label.items()}

    if MANUAL_ID2LABEL_OVERRIDE:
        id2label = {i: MANUAL_ID2LABEL_OVERRIDE.get(name, name) for i, name in id2label.items()}
        logger.info("Manual label override applied: %s", id2label)

    placeholders = [v for v in id2label.values() if v.upper().startswith("LABEL_")]
    if placeholders:
        logger.error(
            "Text emotion model has placeholder labels (%s). Until "
            "TEXT_EMOTION_LABEL_OVERRIDE is filled with actual probe results, "
            "this model's output is unreliable and everything defaults to neutral.",
            placeholders,
        )

    unmapped = sorted({l for l in id2label.values() if l.upper() not in TEXT_MODEL_LABEL_MAP})
    if unmapped:
        logger.warning("These labels are not mapped to any unified class and will fall back to neutral: %s", unmapped)

    return id2label


def _get_model():
    global _model, _tokenizer, _id2label, _device
    if _model is None:
        with _lock:
            if _model is None:
                logger.info("Loading text-emotion model: %s", TEXT_EMOTION_MODEL_PATH)
                _device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
                try:
                    _tokenizer = AutoTokenizer.from_pretrained(TEXT_EMOTION_MODEL_PATH)
                    _model = AutoModelForSequenceClassification.from_pretrained(TEXT_EMOTION_MODEL_PATH)
                except Exception as e:
                    logger.exception("Failed to load text-emotion model")
                    raise TextEmotionError(f"Text emotion model loading failed: {e}") from e
                _model.eval()
                _model.to(_device)
                _id2label = _load_id2label(_model)
                logger.info("Text-emotion model loaded. Raw labels: %s", list(_id2label.values()))
    return _model, _tokenizer, _id2label, _device


def analyze_text_emotion(text: str) -> dict:

    if not text or not text.strip():
        return {label: (1.0 if label == "neutral" else 0.0) for label in UNIFIED_LABELS}

    model, tokenizer, id2label, device = _get_model()

    try:
        inputs = tokenizer(text, return_tensors="pt", truncation=True, padding=True)
        inputs = {k: v.to(device) for k, v in inputs.items()}
        with torch.no_grad():
            logits = model(**inputs).logits
            probs = torch.softmax(logits, dim=-1)[0].cpu().numpy()
    except Exception as e:
        logger.exception("Error running text emotion model")
        raise TextEmotionError(f"Error in text emotion analysis: {e}") from e

    # Aggregate raw class probabilities into unified classes (e.g., HATE + ANGRY -> anger)
    result = {label: 0.0 for label in UNIFIED_LABELS}
    for idx, prob in enumerate(probs):
        raw_label = str(id2label.get(idx, idx)).upper()
        unified = TEXT_MODEL_LABEL_MAP.get(raw_label, "neutral")
        result[unified] += float(prob)

    return result