<p align="center"><img src="docs/img/logo.png" alt="MEIRA logo" width="110"></p>

# MEIRA

Multimodal Edge Intelligence for Recipe Assistance: an offline kitchen and nutrition assistant for Android. Take a
photo of your ingredients, and MEIRA puts a number on each one, reads package labels, and suggests recipes from a
recipe book stored on the phone. It also keeps your meal log, weight, and fasting schedule, and answers questions by
text or voice.

[Bahasa Indonesia](README.id.md)

<p align="center"><img src="docs/img/demo.gif" width="300" alt="Demo: opening, home with the cooking streak, ingredient photo with numbered markers and a recipe, nutrition chat, Gizi Seimbang, recipe book, and the tour"></p>

![Home, ingredient photo, nutrition chat, Gizi Seimbang, and the recipe book](docs/img/tampilan.jpg)

## Features

- Every ingredient in the photo gets its own numbered marker. If a marker is wrong, type the right name, for
  example "ini buah naga" (this is dragon fruit).
- Package text, such as instant noodles or sweet soy sauce, is read with OCR. A photo of the nutrition panel gives
  the values per serving and per pack, a suggested portion, and how they compare with your daily targets.
- Food questions, such as how rendang and kalio differ, are answered from kitchen notes, Wikidata, and USDA facts,
  and MEIRA says so when it has no reliable information.
- Gizi Seimbang: a body calculator (BMI, ideal weight, daily energy and limits), a meal log, weight progress,
  intermittent fasting with reminders, and a daily plan of lighter recipes.
- The assistant uses these features directly: "berat saya 70 kg", "tadi pagi saya makan nasi goreng", or "boleh
  makan sekarang?" are logged or answered from your own data, with a button that opens the feature.
- A cooking grid on the home screen fills in every day you finish a recipe.
- Cooking mode shows one step at a time; timers start on tap or by voice command and notify you when done.
- The recipe book has 285 recipes, including popular dishes such as soto ayam, rawon, pempek, and klepon, with search and filters, and an "Enak & sehat" choice ranks lighter recipes
  first.
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

Two models are fine-tuned for this app: the ingredient detector (D-FINE small, 132 classes from Open Images, LVIS, and Wikimedia Commons photos)
and a 22 MB LoRA chat adapter for Qwen3.5-0.8B instruct that answers food questions only from the facts it is given
and rewrites recipe-book answers in the natural style. On held-out questions the adapter raises fact-based accuracy
from 0.67 to 0.96. The other models are used as released. The VLM eyes and the brain candidate remain research runs:
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
