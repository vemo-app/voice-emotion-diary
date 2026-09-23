# Text Emotion Recognition Model

This directory contains the text emotion recognition model used by the VEMO backend.

## Model

VEMO uses a fine-tuned **XLM-RoBERTa** model for emotion classification from text.

The model files are not included in this repository because of their size. They should be downloaded separately and placed in this directory.

Expected model path:

```text
ml_models/text_emotion/emotion_xlm_roberta_final/
```

The model location is configured through the `TEXT_EMOTION_MODEL_PATH` environment variable.

## Role in VEMO

The model analyzes the emotional content of the transcribed text produced by the Speech-to-Text component.

The resulting emotion prediction can be used as part of VEMO's emotion analysis and empathetic response pipeline.