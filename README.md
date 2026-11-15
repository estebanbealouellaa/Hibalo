# Hibalo

Flutter + Firebase app for Hiligaynon ↔ Filipino translation and learning (Android). Translation,
the Hiligaynon voice and the lessons work offline after sign-in.

## Setup

1. **Git LFS** holds the voice and translation models (`assets/tts/models/*.onnx`,
   `assets/translation/models/*.onnx`). Install it before cloning, or run `git lfs pull` after:
   ```
   git lfs install
   git clone <repo>
   ```
   Without LFS those files are small pointer files and translation and the voice won't load.
2. `flutter pub get`
3. App strings are in `lib/l10n/app_{en,fil,hil}.arb`. After editing them run `flutter gen-l10n`.
4. Firebase settings are in `android/app/google-services.json` and `lib/firebase_options.dart`.
   The Firestore rules are in `firestore.rules` (published from the Firebase console).

## Lessons

- Content: `assets/lessons/` — `learning_settings.json` plus one file per level. Behaviour and
  templates: `docs/LEARNING_BEHAVIOR.md`, `docs/LEARNING_TEMPLATES.md`.
- Filipino lesson text: `assets/lessons/*.fil.json` overlays, made with `tools/lesson_strings.py`:
  ```
  python tools/lesson_strings.py export "<folder>"          # English to CSV, one file per level
  python tools/lesson_strings.py import --dry-run <csv>...  # check filled CSVs
  python tools/lesson_strings.py import <csv>...            # write the overlays
  python tools/lesson_strings.py check                      # check the overlays
  python tools/lesson_strings.py missing <csv>              # texts with no Filipino yet
  ```
- Debug builds have a bug icon on Learn (progress presets, app language, reset, pronunciation
  tuning). It isn't in release builds.

## Tests

```
flutter analyze
flutter test                 # unit and widget tests (~14 min)
flutter test integration_test/<file> -d <device>   # on-device translation and voice checks
```

## Release build (arm64)

```
flutter build apk --release --split-per-abi --target-platform android-arm64 --obfuscate --split-debug-info=build/symbols
```

The APK is `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`. Keep `build/symbols` to
read crash stack traces. Add `android-arm` to `--target-platform` for older 32-bit phones.
Smoke-test the release APK on a phone before sharing it.
