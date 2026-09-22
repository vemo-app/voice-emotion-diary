# Speech Emotion Recognition

This module implements the **Speech Emotion Recognition (SER)** component of VEMO. The goal is to detect emotions from speech recordings and provide a robust emotion classification model that can generalize to **unseen speakers**.

The development process was organized as a sequence of experiments, starting from a pretrained speech emotion recognition model and progressively evaluating different adaptation strategies on real speech data.

## Emotion Classes

The system focuses on four emotion categories:

* Anger
* Happiness
* Sadness
* Neutral

---

## Development Process

The development of the speech emotion recognition system was carried out in
three main stages:

1. **Pretrained Baseline:** Evaluation of a Persian speech emotion recognition
   model pretrained on ShEMO using an independent real-world test set.

2. **Data Augmentation:** Augmentation of ShEMO samples to simulate smartphone
   recording conditions, followed by partial fine-tuning of the pretrained model.

3. **Real-World Data Adaptation:** Evaluation of partial fine-tuning,
   frozen deep representations, and a combination of deep and acoustic
   features, using real speech samples.

The final architecture was selected based on speaker-independent validation
and was subsequently evaluated on a completely independent test set.

---

## 1. Pretrained Baseline

**Directory:** [`01_pretrained_baseline`](./experiments/01_pretrained_baseline)

The first experiment evaluated the pretrained model:

`m3hrdadfi/wav2vec2-xlsr-persian-speech-emotion-recognition`

This model is based on **Wav2Vec2-XLSR** and was previously fine-tuned for Persian speech emotion recognition using the **ShEMO dataset**.

No additional training was performed at this stage. The model was evaluated directly on an independent dataset containing **93 real speech samples from 22 previously unseen speakers**.

This evaluation was designed to examine how well the pretrained model generalizes beyond the data used during its fine-tuning, particularly to new speakers and real-world recording conditions.

### Result

* **Accuracy:** 48%
* **Macro F1-score:** 0.46

The relatively low performance on the independent real-world dataset, compared with the performance reported for the model on its original data, indicated a substantial **domain and speaker generalization gap**.

---

## 2. Data Augmentation

**Directory:** [`02_data_augmentation`](./experiments/02_data_augmentation)

The second stage investigated whether targeted audio augmentation could reduce the gap between the controlled recording conditions of **ShEMO** and the more variable conditions expected in real-world smartphone recordings.

The augmentation process was applied to the ShEMO samples belonging to the four target emotion classes:

* Anger
* Happiness
* Sadness
* Neutral

The resulting training data contained **both the original ShEMO samples and their augmented versions**.

### Augmentation Pipeline

The augmentation pipeline was designed to simulate common variations introduced by smartphone recording environments. The following transformations were applied independently with predefined probabilities, allowing different combinations of transformations to be generated for different samples:

* **Background noise:** Real environmental noises from the **MUSAN** dataset were added at randomly selected signal-to-noise ratios (SNRs). A small proportion of samples was exposed to stronger noise levels to improve robustness.
* **Reverberation:** Mild room reverberation was simulated by convolving the audio signal with synthetic impulse responses with exponentially decaying characteristics.
* **Microphone frequency response:** A high-pass filter was used to simulate the attenuation of low-frequency components that can occur in smartphone microphones.
* **Automatic Gain Control (AGC):** Random gain variation followed by dynamic-range compression was applied to approximate the behavior of automatic gain control during smartphone recording.
* **Audio codec simulation:** Audio samples were encoded and decoded using commonly used codecs such as **AAC** and **Opus** to simulate distortions introduced by real-world audio compression.

Because ShEMO is not perfectly balanced across the target emotion classes, the amount of augmentation was adjusted by class. Classes with fewer original samples received a higher augmentation factor than the most represented class. This increased the overall training data while also reducing the relative class imbalance.

As a quality-control step, augmented samples that became effectively silent after the sequence of transformations were detected and removed.

A metadata file containing both original and augmented samples was then generated for training. The metadata included information such as the audio path, speaker ID, gender, emotion label, and whether each sample was original or augmented.

### Model Training

The augmented training set was used to fine-tune the pretrained Wav2Vec2-based model.

The convolutional feature extractor remained frozen, while the **last two transformer encoder layers** and the classification head were updated using the combined original and augmented ShEMO data.

The model was configured for the four target emotion classes.

The purpose of this stage was to make the learned representations more robust to acoustic variations that may occur in real-world smartphone recordings.

### Evaluation

The resulting model was evaluated on the same independent test set used for the pretrained baseline:

* **93 real speech samples**
* **22 previously unseen speakers**
* Four target emotion classes

### Result

* **Accuracy:** 45%
* **Macro F1-score:** 0.43

The augmentation-based fine-tuning approach did **not improve performance on the independent real-world test set**, compared with the pretrained baseline (48% accuracy, macro F1-score of 0.46).

This result suggested that simulating recording variations through augmentation alone was not sufficient to close the gap between the ShEMO training domain and the project's real-world speech data. Consequently, the development process proceeded to experiments using actual target-domain speech samples.

---

## 3. Real-World Data Experiments

**Directory:** [`03_real_data`](./experiments/03_real_data)

The next stage focused directly on the project's real speech data.

A dataset of **112 real speech samples** was used for speaker-independent validation. The experiments investigated several approaches for adapting speech representations to the target data while reducing the risk of overfitting to individual speakers.

### 3.1 Fine-Tuning

**Directory:** [`01_finetuning`](./experiments/03_real_data/01_finetuning)

In this experiment, the Wav2Vec2 model was partially fine-tuned on the real speech data.

The evaluation was performed using speaker-independent validation splits to ensure that speakers in the validation data were not seen during training.

The results showed that directly fine-tuning the model did not provide a reliable improvement compared with using frozen representations.

---

### 3.2 Deep Features

**Directory:** [`02_deep_features`](./experiments/03_real_data/02_deep_features)

In this approach, The Wav2Vec2 backbone obtained after the fine-tuning stage in Section 2 was kept frozen (its classification head was discarded), and used purely as a feature extractor.

Deep speech representations were extracted from the real speech samples, and a Logistic Regression classifier was trained using these representations.

Speaker-independent validation was used for evaluation.

### Result

* **Accuracy:** 67%
* **Macro Precision:** 0.68
* **Macro Recall:** 0.67
* **Macro F1-score:** 0.67

This approach provided substantially better performance than the initial pretrained baseline and the augmentation experiment.

---

### 3.3 Deep Features + Acoustic Features

**Directory:** [`03_deep_plus_acoustic`](./experiments/03_real_data/03_deep_plus_acoustic)

The final experiment in this stage combined the deep representations extracted from Wav2Vec2 with complementary **acoustic features**.

The Wav2Vec2 backbone remained frozen, while a classifier was trained using the combined feature representation.

Speaker-independent validation was again used to evaluate generalization to unseen speakers.

### Result

* **Accuracy:** 70%
* **Macro Precision:** 0.70
* **Macro Recall:** 0.70
* **Macro F1-score:** 0.69

The combination of deep speech representations and acoustic features performed better than using deep representations alone.

---

## Experimental Comparison

| Approach                 | Evaluation                     | Accuracy | Macro F1 |
| ------------------------ | ------------------------------ | -------: | -------: |
| Pretrained baseline      | Independent test (93 samples)  |      48% |     0.46 |
| Data augmentation        | Independent test (93 samples)  |      45% |     0.43 |
| Fine-tuning              | Speaker-independent validation |      47% |     0.45 |
| Deep features            | Speaker-independent validation |      67% |     0.67 |
| Deep + acoustic features | Speaker-independent validation |      70% |     0.69 |

> **Note:** The 93-sample independent test set and the 112-sample speaker-independent validation dataset are different evaluation settings and should not be directly treated as identical benchmarks.

---

# Final Model

Based on the experimental results, the final architecture uses:

**Frozen Wav2Vec2 representations + acoustic features + classifier**

The Wav2Vec2 backbone is kept frozen, and its learned speech representations are combined with complementary acoustic features before classification.

This approach was selected for the final system because it provided the strongest performance among the evaluated approaches while avoiding the instability observed with partial fine-tuning.

The final model was then evaluated on the independent test set containing **93 speech samples from 22 unseen speakers**.

### Final Independent Test Result

* **Accuracy:** 74%
* **Macro Precision:** 0.75
* **Macro Recall:** 0.74
* **Macro F1-score:** 0.74

The final independent test performance was consistent with the approximately 70% performance observed during speaker-independent validation, supporting the use of the selected architecture for unseen-speaker speech emotion recognition.

---

## Final Architecture

```text
                    Input Speech
                         │
                         ▼
                  ┌─────────────┐
                  │   Wav2Vec2  │
                  │   Backbone  │
                  │   (Frozen)  │
                  └──────┬──────┘
                         │
                  Deep Speech Features
                         │
                         ├───────────────┐
                         │               │
                         │        Acoustic Features
                         │               │
                         └───────┬───────┘
                                 ▼
                         Feature Combination
                                 │
                                 ▼
                              Classifier
                                 │
                                 ▼
                    ┌─────────────────────┐
                    │  Emotion Prediction │
                    └─────────────────────┘
                                 │
                 ┌───────────────┼───────────────┐───────────────┐
                 ▼               ▼               ▼               ▼
              Anger          Happiness         Sadness         Neutral
                                                 
```

---

## Repository Structure

```text
Speech_Emotion_Recognition/
│
├── experiments/
│   │
│   ├── 01_pretrained_baseline/
│   │   └── evaluate.ipynb
│   │
│   ├── 02_data_augmentation/
│   │   ├── train.ipynb
│   │   └── evaluate.ipynb
│   │
│   └── 03_real_data/
│       │
│       ├── 01_finetuning/
│       │   └── train_and_evaluate.ipynb
│       │ 
│       │
│       ├── 02_deep_features/
│       │   └── train_and_evaluate.ipynb
│       │
│       └── 03_deep_plus_acoustic/
│           └── train_and_evaluate.ipynb
│
└── README.md
```

Each experiment is kept separately to preserve the development process and make it possible to reproduce and compare the different approaches.

---

## Key Takeaways

* The pretrained model showed limited generalization to our independent real-world speech data.
* Data augmentation did not improve performance on the independent test set.
* Using Wav2Vec2 as a frozen feature extractor provided a substantial improvement.
* Combining deep speech representations with acoustic features further improved speaker-independent validation performance.
* Partial fine-tuning performed less reliably than using a frozen backbone.
* The final frozen-backbone architecture with combined deep and acoustic features achieved **74% accuracy and 0.74 macro F1-score** on the independent test set.

The experiments demonstrate the progression from a pretrained baseline to a model specifically adapted for VEMO's speech emotion recognition task.

---

### References

[1] m3hrdadfi, *"wav2vec2-xlsr-persian-speech-emotion-recognition."* [Online]. Available: https://huggingface.co/m3hrdadfi/wav2vec2-xlsr-persian-speech-emotion-recognition

[2] O. Mohamad Nezami, P. Jamshid Lou, and M. Karami, *"ShEMO: A large-scale validated database for Persian speech emotion detection,"* Language Resources and Evaluation, vol. 53, no. 1, pp. 1–16, 2019.

[3] D. Snyder, G. Chen, and D. Povey, "MUSAN: A music, speech, and noise corpus," arXiv preprint arXiv:1510.08484, 2015.

---

## Model Weights

The trained model weights are not included directly in this repository due to
their file size.

The model files can be downloaded from:

[Download Model Weights](https://huggingface.co/maryamalikhasi/vemo-speech-emotion-recognition)