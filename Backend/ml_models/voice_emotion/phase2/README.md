# Voice Emotion Recognition — Phase 2

This directory contains the **Phase 2** classification component of VEMO's Speech Emotion Recognition pipeline.

## Components

Phase 2 consists of:

* **Logistic Regression classifier**
* **Feature scaler**
* **Metadata**

Expected files:

```text
phase2/
├── logistic_classifier.joblib
├── scaler.joblib
└── metadata.json
```

These files are not included in this repository because model artifacts are stored separately on Hugging Face.

## Hugging Face

The trained model components are available in the VEMO Hugging Face repository:

[Download trained model components](https://huggingface.co/maryamalikhasi/vemo-speech-emotion-recognition)

The Phase 2 files are located under:

```text
phase2/
```

## Role in VEMO

The Phase 2 classifier receives the speech representation produced by the Phase 1 encoder together with the selected acoustic features and predicts the corresponding emotion class.

The final pipeline uses the Phase 1 Wav2Vec2 representation together with acoustic features, followed by scaling and Logistic Regression classification.