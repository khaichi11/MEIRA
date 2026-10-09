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

| Role | Model | Source | Runtime | Size |
|---|---|---|---|---:|
| Ingredient markers | D-FINE small | trained for MEIRA in MEIRA-Before | ONNX Runtime | 42 MB, inside the APK |
| Package reader | PP-OCRv5 mobile | PaddleOCR, used as released | ONNX Runtime | 13 MB, inside the APK |
| Conversation and finished dishes | Qwen3.5-0.8B instruct | [unsloth/Qwen3.5-0.8B-GGUF](https://huggingface.co/unsloth/Qwen3.5-0.8B-GGUF), used as released | llama.cpp | 0.7 GB, downloaded once |
| Speech to text | Whisper small int8 | [csukuangfj/sherpa-onnx-whisper-small](https://huggingface.co/csukuangfj/sherpa-onnx-whisper-small), used as released | sherpa-onnx | 0.4 GB, downloaded once |
| Voice | the phone's TTS engine | Android | Android | |

The downloaded models come from these public Hugging Face repositories, not from a MEIRA account. The full APK built
with `tool/build_full_apk.sh` carries the same files, so nothing needs to be downloaded.

The ingredient marker is still being improved; current results and known weaknesses are in the
[MEIRA-Before evaluation](https://github.com/khaichi11/MEIRA-Before/blob/main/docs/en/evaluation.md).

## Tech stack

| Layer | Tools |
|---|---|
| App | Flutter 3.41, Dart 3.11, Material 3, Inter and Poppins fonts |
| On-device inference | ONNX Runtime 1.30 over FFI for the detector and OCR, llama.cpp `llama-server` for the language model, sherpa-onnx for Whisper |
| Retrieval | BM25 over the recipe book and kitchen notes, plus name lookup over 4,085 Wikidata (CC0) and USDA (public domain) food facts |
| Storage | SQLite (sqflite) and shared_preferences |
| Platform | Android 9 or newer; voice through the phone's TTS engine (flutter_tts) |
| Tooling | flutter test, dart format, ffmpeg and Pillow for the demo images |

Two models are fine-tuned for this app: the ingredient detector (D-FINE small, 60 epochs on 3,842 photos, 90 classes)
and a 22 MB LoRA chat adapter for Qwen3.5-0.8B instruct that answers food questions only from the facts it is given
and rewrites recipe-book answers in the natural style. On held-out questions the adapter raises fact-based accuracy
from 0.72 to 0.98. The other models are used as released. The VLM eyes and the brain candidate remain research runs:
the detector proved more accurate and faster than the eyes. All runs are listed in
[MEIRA-Before](https://github.com/khaichi11/MEIRA-Before#fine-tuned-models).

## Requirements

- Android 9 or newer, arm64, at least 6 GB of RAM (8 GB recommended).
- About 1.2 GB of free space for the downloaded models, or about 2.5 GB for the full APK that already contains them.

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
