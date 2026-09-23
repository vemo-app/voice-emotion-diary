# Voice Emotion Recognition — Phase 1

This directory contains the **Phase 1** model component of VEMO's Speech Emotion Recognition pipeline.

## Model

Phase 1 uses a **Wav2Vec2-based speech encoder** to extract deep representations from speech audio.

The encoder is used as a frozen feature extractor in the final VEMO voice emotion recognition pipeline.

The model files are not included in this repository because of their size. They are hosted separately on Hugging Face.

## Hugging Face

The trained model components are available in the VEMO Hugging Face repository:

[Download trained model components](https://huggingface.co/maryamalikhasi/vemo-speech-emotion-recognition)

The Phase 1 files are located under:

```text
phase1/
```

## Role in VEMO

The encoder converts an input speech recording into a deep speech representation. This representation is then passed to the Phase 2 classifier together with the required preprocessing steps.
