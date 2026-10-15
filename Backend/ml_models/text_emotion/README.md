# Text Emotion Recognition

This directory contains the text-based emotion recognition model used by the VEMO backend to detect emotions from the corrected transcript of a voice memory.

## Model

VEMO uses a **fine-tuned XLM-RoBERTa-large** model for Persian text emotion classification.

The model was developed in two fine-tuning stages:

1. **Stage 1:** Fine-tuned on [ArmanEmo](https://github.com/Arman-Rayan-Sharif/arman-text-emotion), a public Persian text emotion dataset.
2. **Stage 2:** Further fine-tuned on a custom dataset of 615 labeled Persian text samples to better adapt the model to informal, spoken-style text.

The model supports four unified emotion classes:

- `anger`
- `happiness`
- `sadness`
- `neutral`

Its original seven-class output is mapped to these four classes, with `hate` mapped to `anger`, `fear` mapped to `sadness`, and `surprise` mapped to `neutral`.

## Model Weights

The trained models are hosted on Hugging Face and are not included directly in this repository.

- **Base model (Stage 1):** [maryamalikhasi/text-emotion-xlm-roberta-large](https://huggingface.co/maryamalikhasi/text-emotion-xlm-roberta-large)
- **Final model (Stage 2):** [ftmjfr/VEMO-final-text-emotion-recognition](https://huggingface.co/ftmjfr/VEMO-final-text-emotion-recognition)

The backend uses the final model for text emotion recognition.

## Label Mapping

Some model checkpoints may expose their output classes using placeholder labels such as `LABEL_0`, `LABEL_1`, and so on, rather than descriptive emotion names.

If the loaded checkpoint uses placeholder labels, the `TEXT_EMOTION_LABEL_OVERRIDE` environment variable can be used to provide an explicit JSON mapping. For example:

```bash
TEXT_EMOTION_LABEL_OVERRIDE='{"LABEL_0": "SAD", "LABEL_1": "NEUTRAL", "LABEL_2": "ANGRY", "LABEL_3": "HAPPY"}'
```

The mapping must match the actual class-to-index order of the loaded checkpoint. If placeholder labels are detected and no valid mapping is provided, the service logs an error and defaults predictions to `neutral`.

## Download the Model

Download the final fine-tuned model from Hugging Face:

**[VEMO Final Text Emotion Recognition](https://huggingface.co/ftmjfr/VEMO-final-text-emotion-recognition)**

After downloading the model files, place them in the following directory:

```text
Backend/ml_models/text_emotion/emotion_xlm_roberta_final/
```

The model location is configured through the `TEXT_EMOTION_MODEL_PATH` environment variable.

## Label Mapping

If the downloaded checkpoint reports its classes as placeholder labels (`LABEL_0`, `LABEL_1`, ...) instead of actual class names, set the `TEXT_EMOTION_LABEL_OVERRIDE` environment variable to a JSON mapping, e.g.:

```bash
TEXT_EMOTION_LABEL_OVERRIDE='{"LABEL_0": "SAD", "LABEL_1": "NEUTRAL", "LABEL_2": "ANGRY", "LABEL_3": "HAPPY"}'
```

Without this mapping, if placeholder labels are detected, the service logs an error and all predictions default to `neutral`.

## Role in VEMO

The text emotion model receives the corrected transcript (produced by the LLM-based text correction component) and predicts a confidence score for each of the four supported emotions. Its output is later combined with the voice emotion model's output to form the final emotion assessment for a memory.