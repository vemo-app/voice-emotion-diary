# Text Emotion Recognition

This directory contains the text-based emotion recognition model used by the VEMO backend to detect emotions from the corrected transcript of a voice memory.

## Model

VEMO uses a **fine-tuned XLM-RoBERTa** model for text emotion classification.

The model was fine-tuned on a combination of custom-labeled data and the Arman emotion dataset, and its output taxonomy was reduced to four classes (`anger`, `happiness`, `sadness`, `neutral`) to match the voice emotion model's supported classes.

The model files are not included in this repository because of their size. They are hosted separately on Hugging Face.

## Hugging Face

The trained model is available in the VEMO Hugging Face repository:

[Download trained model]()

Expected model path:

\`\`\`text
ml_models/text_emotion/emotion_xlm_roberta_final/
\`\`\`

The model location is configured through the `TEXT_EMOTION_MODEL_PATH` environment variable.

## Label Mapping

If the downloaded checkpoint reports its classes as placeholder labels (`LABEL_0`, `LABEL_1`, ...) instead of actual class names, set the `TEXT_EMOTION_LABEL_OVERRIDE` environment variable to a JSON mapping, e.g.:

\`\`\`bash
TEXT_EMOTION_LABEL_OVERRIDE='{"LABEL_0": "SAD", "LABEL_1": "NEUTRAL", "LABEL_2": "ANGRY", "LABEL_3": "HAPPY"}'
\`\`\`

Without this mapping, if placeholder labels are detected, the service logs an error and all predictions default to `neutral`.

## Role in VEMO

The text emotion model receives the corrected transcript (produced by the LLM-based text correction component) and predicts a confidence score for each of the four supported emotions. Its output is later combined with the voice emotion model's output to form the final emotion assessment for a memory.