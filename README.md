<p align="center"><img src="docs/img/logo.png" alt="MEIRA logo" width="110"></p>

# MEIRA

Multimodal Edge Intelligence for Recipe Assistance: an offline kitchen assistant for Android. Take a photo of
your ingredients, and MEIRA puts a number on each one, reads package labels, and suggests recipes from a recipe book
stored on the phone. Ask follow-up questions by typing or speaking.

[Bahasa Indonesia](README.id.md)

<p align="center"><img src="docs/img/demo.gif" width="300" alt="Demo: opening, nickname, ingredient photo, numbered markers, recipe, follow-up questions, extra ingredients, cooking mode, and the other tabs"></p>

![App screens](docs/img/tampilan.jpg)

## Features

- Every ingredient in the photo gets its own numbered marker. Tap a wrong number to fix it.
- Package text, such as instant noodles, cooking oil, or sweet soy sauce, is read with OCR.
- Ingredients can be added from a second photo or by typing, for example "ada telur juga" (there is egg too).
- The home screen holds the recipe book, with filters for quick meals, breakfast, no-stove dishes, drinks, and soups.
- Questions can be typed or spoken. Cooking mode shows one step at a time, with a timer where the recipe needs one.
- Recipes and steps come from the recipe book, and kitchen questions are answered from hand-written notes.
- Harmful or off-topic requests get a short, polite refusal.
- History stays on the phone with size limits, and MEIRA greets you by your nickname.
- Once the models are downloaded, nothing needs the internet and no data leaves the phone.

## Models

| Role | Model | Runtime | Size |
|---|---|---|---:|
| Ingredient markers | D-FINE small, trained by MEIRA | ONNX Runtime | 42 MB, inside the APK |
| Package reader | PP-OCRv5 mobile | ONNX Runtime | 13 MB, inside the APK |
| Conversation and finished dishes | Qwen3.5-0.8B instruct | llama.cpp | 0.7 GB, downloaded once |
| Speech to text | Whisper small int8 | sherpa-onnx | 0.4 GB, downloaded once |
| Voice | the phone's TTS engine | Android | |

The ingredient marker is still being improved; current results and known weaknesses are in the
[MEIRA-Before evaluation](https://github.com/khaichi11/MEIRA-Before/blob/main/docs/en/evaluation.md).

## Tech stack

| Layer | Tools |
|---|---|
| App | Flutter 3.41, Dart 3.11, Material 3, Inter and Poppins fonts |
| On-device inference | ONNX Runtime 1.30 over FFI for the detector and OCR, llama.cpp `llama-server` for the language model, sherpa-onnx for Whisper |
| Retrieval | BM25 over the recipe book and kitchen notes |
| Storage | SQLite (sqflite) and shared_preferences |
| Platform | Android 9 or newer; voice through the phone's TTS engine (flutter_tts) |
| Tooling | flutter test, dart format, ffmpeg and Pillow for the demo images |

Only the ingredient detector is fine-tuned for this app (D-FINE small, 60 epochs on 3,842 photos, 90 classes). The
other models are used as released. Training runs, including the LoRA experiments on Qwen3.5, are listed in
[MEIRA-Before](https://github.com/khaichi11/MEIRA-Before#fine-tuned-models).

## Requirements

- Android 9 or newer, arm64, at least 6 GB of RAM (8 GB recommended).
- About 1.2 GB of free space for the downloaded models.

## Build and test

```bash
flutter pub get
tool/build_native.sh            # llama-server and ONNX Runtime for Android, needs the Android NDK
flutter build apk --release
flutter test
```

## Documentation

| English | Bahasa Indonesia |
|---|---|
| [Architecture](docs/en/architecture.md) | [Arsitektur](docs/id/arsitektur.md) |
| [Development](docs/en/development.md) | [Pengembangan](docs/id/pengembangan.md) |
| [Licenses](LICENSES.md) | [Lisensi](LICENSES.md) |

Data, training, and evaluation live in [MEIRA-Before](https://github.com/khaichi11/MEIRA-Before).

## License

Code is Apache-2.0. The logo, recipe book, and kitchen notes are CC0. Third-party models and libraries are listed in
[LICENSES.md](LICENSES.md) and under Settings > Licenses in the app.
