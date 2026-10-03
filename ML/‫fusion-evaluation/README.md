# Fusion Evaluation

End-to-end evaluation of the full pipeline — speech-to-text, text-based
emotion detection, and voice-based emotion detection — on 93 of our own
recorded samples, including how well combining the text and voice signals
works compared to either alone.

## Structure

```
fusion-evaluation/
├── fusion_evaluation.ipynb
├── full_pipeline_results.csv      # per-sample predictions, all stages
├── reference_vs_predicted.csv     # per-sample comparison + error flags
├── full_pipeline_summary.csv      # single-row summary of all metrics
├── fusion_summary.csv             # text-only / audio-only / combined table
└── README.md
```

## What it does

For each audio sample:
1. **STT** — transcribes the audio (`openai/whisper-large-v3`), with the
   audio loudness-normalized (-23 LUFS) and silence-trimmed beforehand, and
   computes WER against the reference transcript.
2. **Text emotion** — classifies the transcript's emotion with the
   fine-tuned XLM-RoBERTa model.
3. **Voice emotion** — classifies the audio directly using a ShEMO-trained
   Wav2Vec2 encoder + 8 hand-crafted prosodic features (f0, RMS, ZCR,
   spectral centroid) fed into a logistic regression head.
4. **Fusion** — combines both models' probability vectors as
   `(audio_probs + text_probs) / 2`, and evaluates the combined prediction
   against the same ground truth.

All three signals (text-only, audio-only, combined) are evaluated on the
same 4-class taxonomy (anger, happiness, sadness, neutral).

## Models used

- **Text emotion:** [ftmjfr/VEMO-final-text-emotion-recognition](https://huggingface.co/ftmjfr/VEMO-final-text-emotion-recognition) (Hugging Face)
- **Voice emotion:** ShEMO-trained Wav2Vec2 encoder + logistic regression
  classifier (downloaded from Google Drive at notebook runtime — see the
  `gdown` cells near the top of the notebook)

## Results

93 samples, 4 classes (anger, happiness, sadness, neutral):

| Stage | Metric | Value |
|---|---|---|
| STT | WER | 34.2% |
| STT | Accuracy (1 − WER) | 65.8% |
| Text emotion | Accuracy | 81.7% |
| Text emotion | Macro-F1 | 81.9% |
| Voice emotion | Accuracy | 74.2% |
| Voice emotion | Macro-F1 | 74.0% |
| **Fusion (audio+text)/2** | Accuracy | 82.8% |
| **Fusion (audio+text)/2** | Macro-F1 | 82.9% |

Fusion outperforms both individual modalities here — combining text and
voice predictions gives a real accuracy gain over either signal alone.

## Downstream usage

The combined emotion produced by this fusion step is what gets passed
further in the pipeline to generate the empathetic response shown to the
user — this notebook evaluates the classification step itself, not the
generated feedback text.

## Requirements

```
torch
transformers
librosa
soundfile
jiwer
hazm
pyloudnorm
scikit-learn
pandas
joblib
gdown
huggingface_hub
```
