# Text Emotion Recognition

Persian text emotion classification model, developed in three training stages
and evaluated against both public benchmarks and our own collected data.

## Overview

The final model classifies Persian text into **4 unified emotion classes**:
`anger`, `happiness`, `sadness`, `neutral`.

It is built in two fine-tuning stages on top of XLM-RoBERTa-large:

1. **Stage 1** — fine-tuned on [ArmanEmo](https://github.com/Arman-Rayan-Sharif/arman-text-emotion),
   a public Persian text emotion dataset (7 original classes: anger, happiness,
   sadness, neutral, fear, surprise, hate).
2. **Stage 2** — further fine-tuned on our own 615-sample labeled dataset to
   adapt the model to real, informal, spoken-style Persian text (as opposed to
   ArmanEmo's more formal/written text).

At inference time, the model's 7-class output is folded into the 4 unified
classes (`hate → anger`, `fear → sadness`, `surprise → neutral`), matching how
the model is used in production.

## Structure

```
Text_Emotion_Recognition/
├── parsbert_baseline.ipynb
├── xlm_roberta_arman.ipynb
├── finetune_xlm_roberta_large_on_own_data.ipynb
├── evaluate_final_model.ipynb
└── README.md
```

## Pipeline

| Notebook | What it does |
|---|---|
| `parsbert_baseline(experiment).ipynb` | Initial baseline using ParsBERT, a monolingual Persian model |
| `xlm_roberta_arman.ipynb` | Trains XLM-RoBERTa-large on ArmanEmo (stage 1) |
| `finetune_xlm_roberta_large_on_own_data.ipynb` | Fine-tunes the stage-1 model on our own 615-sample dataset (stage 2) |
| `evaluate_final_model.ipynb` | Evaluates the final (stage 2) model against the base (stage 1) model on three test sets: ArmanEmo, ShEMO, and our own VEMO data |

## Why only 4 classes for ShEMO evaluation

ShEMO originally has 6 emotion classes (anger, happiness, sadness, neutral,
fear, surprise). Only 4 are used throughout this project (data augmentation,
training, and evaluation):

- Fear and surprise have far fewer samples in ShEMO than the other classes.
- Naturally inducing fear/surprise in a short, prompted recording is
  unreliable in practice, which matters since the project also evaluates on
  real, self-collected recordings.
- For the target use case (emotion detection in everyday voice diaries),
  anger, happiness, sadness, and neutral are the more central emotions.

## Results

Final (stage 2) model vs. base (stage 1) model, evaluated on three datasets:

| Model | Dataset | Accuracy | Macro-F1 |
|---|---|---|---|
| final model | ArmanEmo (test split) | 0.66 | 0.67 |
| final model | ShEMO (transcripts) | 0.54 | 0.44 |
| final model | VEMO (our own 112-sample set) | 0.88 | 0.88 |
| base model | ArmanEmo (test split) | 0.77 | 0.77 |
| base model | ShEMO (transcripts) | 0.42 | 0.36 |
| base model | VEMO (our own 112-sample set) | 0.81 | 0.80 |

The final model trades a bit of accuracy on the public benchmarks (ArmanEmo,
ShEMO) for a large gain on VEMO, our own real-world test set — which is the
actual target domain for this project.

## Model weights

- **Base model (stage 1):** [maryamalikhasi/text-emotion-xlm-roberta-large](https://huggingface.co/maryamalikhasi/text-emotion-xlm-roberta-large)
- **Final model (stage 2):** [ftmjfr/VEMO-final-text-emotion-recognition](https://huggingface.co/ftmjfr/VEMO-final-text-emotion-recognition)

## Datasets

- **ArmanEmo** (public, stage 1 training + evaluation): [github.com/Arman-Rayan-Sharif/arman-text-emotion](https://github.com/Arman-Rayan-Sharif/arman-text-emotion)
- **ShEMO** (public, evaluation only, transcripts): [github.com/mansourehk/ShEMO](https://github.com/mansourehk/ShEMO)
- **Our fine-tuning dataset** (615 samples, stage 2 training): [kaggle.com/datasets/ftmjfr/emotion-transcripts](https://www.kaggle.com/datasets/ftmjfr/emotion-transcripts)
- **VEMO** (our own 112-sample evaluation set): private, not included in this repository

## Requirements

```
transformers
torch
datasets
accelerate
pandas
scikit-learn
openpyxl
```
