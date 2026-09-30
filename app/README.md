# Voice Diary — Mobile App

Flutter mobile app for recording daily voice entries, detecting the
speaker's emotion (via the backend's speech-to-text + emotion models), and
showing history, analytics, and AI-generated feedback.

## Features

- **Voice recording & entries** — record a voice memo, view/edit past
  entries by day, browse history on a calendar (Jalali/Persian calendar
  supported)
- **Emotion detection** — entries are classified into 4 emotions (happy,
  sad, anger, neutral), each with its own color and emoji
- **Analytics** — emotion trends/reports over time
- **AI feedback** — page for AI-generated feedback on entries
- **Auth** — login / signup, token-based, stored securely on-device
- **Localization** — full Persian and English support (`l10n/`)
- **Theming** — light/dark mode, persisted across sessions

## Structure

```
lib/
├── main.dart                  # app entry point
├── l10n/                      # Persian/English localization (.arb + generated)
├── models/                    # data models (Emotion, MemoryEntry, UserProfile, reports)
├── pages/                     # one folder per screen
│   ├── ai_feedback/
│   ├── analystics/
│   ├── history/
│   ├── home/
│   ├── login/
│   ├── new_memory/
│   ├── profile/
│   ├── root/                  # auth gate / routing
│   ├── settings/
│   └── signup/
├── services/                  # API clients, auth, storage, theming, date utils
└── widgets/                   # shared UI components
```

## Architecture

- `ApiClient` (`services/api_client.dart`) holds the backend base URL and
  shared headers; all other services (`AuthService`, `EntriesService`,
  `AnalyticsService`, `UserService`, `VoiceNoteService`) build on top of it.
- Auth tokens are stored with `flutter_secure_storage` (Keychain on iOS,
  Keystore on Android), not in plain local storage.
- Theme and locale preferences are persisted with `shared_preferences` and
  applied at app startup (`ThemeService`, `LocaleService`).
- Dates are converted between Gregorian and Jalali calendars client-side
  (`jalali_converter.dart`).

## Requirements

- Dart SDK `^3.12.2` (comes with a matching Flutter SDK)

Key packages:

| Package | Version | Used for |
|---|---|---|
| `http` | ^1.6.0 | API calls to the backend |
| `flutter_secure_storage` | ^11.0.0 | Storing the auth token (Keychain/Keystore) |
| `shared_preferences` | ^2.2.2 | Theme and locale persistence |
| `record` | ^7.1.1 | Recording voice memos |
| `just_audio` | 0.10.6 | Playing back recorded audio |
| `audio_session` | 0.2.4 | Audio session config (mic/playback) |
| `image_picker` | ^1.1.2 | Picking images (e.g. profile photo) |
| `path_provider` | ^2.1.4 | Local file paths for recordings |
| `google_fonts` | ^8.2.1 | Typography |
| `flutter_localizations` + `intl` | sdk / any | Persian/English localization |
| `flutter_launcher_icons` | ^0.14.1 | App icon generation (dev tool) |
| `cupertino_icons` | ^1.0.8 | iOS-style icons |

Dev: `flutter_lints ^6.0.0`, `flutter_test`.

Targets: Android, iOS, and Web (the `android/` and `web/` folders are part of
the repo; app icons are generated for both from `assets/icon/icon.png`).

## Setup

```bash
flutter pub get
flutter gen-l10n      # regenerates lib/l10n/app_localizations*.dart from the .arb files
flutter run
```

Localization is driven by `l10n.yaml` (arb files in `lib/l10n/`, Persian
(`app_fa.arb`) as the template, English (`app_en.arb`) as the translation).

## Configuration

⚠️ The backend base URL is currently hardcoded in `services/api_client.dart`:

```dart
static const String baseUrl = 'https://brought-strewn-repose.ngrok-free.dev/api/v1';
```

This is a temporary [ngrok](https://ngrok.com) tunnel — it will stop working
whenever the tunnel is restarted, and shouldn't be relied on by anyone
cloning this repo. Before/after publishing, consider moving this to an
environment-specific config (e.g. `--dart-define`, a `.env` file with
`flutter_dotenv`, or separate dev/prod constants) so the repo doesn't ship a
dead or environment-specific URL.

## Related

- Backend: `backend/` (FastAPI service, incl. `text_emotion_service.py`)
- ML models: `Text_Emotion_Recognition/`, `Speech_To_Text/` — see their
  respective READMEs
