# Speech-to-text

Model selection and audio preprocessing for the STT stage of VEMO. Both
notebooks evaluate on the same 112-sample private dataset (`voice_dataset/`:
`audio/` + `metadata.xlsx`, not included in this repository).

## Notebooks

**`stt-model-comparison.ipynb`** — compares five candidate Persian STT models
(Whisper large-v3, a Persian Whisper fine-tune, two Wav2Vec 2.0 + CTC Persian
fine-tunes, and a FastConformer model) by corpus-level WER. `openai/whisper-large-v3`
had the lowest WER and was selected as the STT model for VEMO.

**`stt-preprocessing-comparison.ipynb`** — with the model fixed to
`openai/whisper-large-v3`, compares six audio preprocessing configurations
(raw, denoise, loudness normalization, silence trimming, and combinations)
by WER, plus a per-sample error breakdown (substitutions / deletions /
insertions) for the winning configuration.

## Result

| Stage | Winner | WER |
|---|---|---|
| Model selection | `openai/whisper-large-v3` | 35.33% (raw preprocessing) |
| Preprocessing | loudness normalization + silence trimming (no denoise) | 34.28% |

`openai/whisper-large-v3` with loudness normalization + silence trimming is
the configuration deployed in the VEMO backend. No fine-tuning was performed
on the STT model.

## Reproducing

Both notebooks expect a Kaggle GPU accelerator, internet access (to download
model weights), and `DATASET_ROOT` pointed at a local copy of `voice_dataset`.
The dataset itself is not distributed with this repository.

