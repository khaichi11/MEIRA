# Development guide

[Bahasa Indonesia](../id/pengembangan.md)

## Prerequisites

- Flutter 3.41 or newer with Dart 3.11.
- Android SDK with the NDK and CMake.
- The [MEIRA-Before](https://github.com/khaichi11/MEIRA-Before) repository in the parent folder if you want to refresh
  shared data or run tests with real models.

## Native libraries

```bash
ANDROID_NDK=~/Android/Sdk/ndk/<version> tool/build_native.sh
```

The script builds `llama-server` from llama.cpp `b11476` for arm64-v8a and x86_64, then fetches the official ONNX
Runtime 1.30.0 from Maven. Everything is copied to `android/app/src/main/jniLibs/`, which is not tracked in git.

- `llama-server` is packaged as `libllama_server.so` because Android only allows executables from the native library
  folder. `useLegacyPackaging` makes sure files are extracted to disk.
- The full ONNX Runtime is packaged as `libonnxruntime_meira.so`, with its SONAME changed by `patchelf`, next to the
  trimmed `libonnxruntime.so` that sherpa-onnx brings. The detector needs operators the trimmed build lacks, while
  sherpa-onnx is linked against the versioned symbols of its own build (`VERS_1.28.2`), so Whisper only loads with
  that library. Replacing one with the other breaks either the detector or voice input.

## Models inside the APK

`assets/models/` holds the ingredient detector and OCR (about 55 MB). The detector is exported from MEIRA-Before:

```bash
.venv-train/bin/python scripts/export_detector.py --model runs/meira-det-small --name meira-det-small
.venv-train/bin/python scripts/eval_detector.py --onnx models/app/meira-det-small.onnx --model runs/meira-det-small \
    --name "MEIRA detektor small" --threads 4      # writes thresholds to meira-det-small.json
```

Copy `meira-det-small.onnx`, `.labels.txt`, and `.json` into `assets/models/` as `meira-det.*`.

The chat LoRA adapter (`meira-chat-lora-f16.gguf`, about 22 MB) is trained in MEIRA-Before and copied into
`assets/models/`. It is not kept in git; when it is missing at build time, the app still runs with the base model.
On start-up the adapter is copied to the models folder and loaded into `llama-server` with
`--lora-init-without-apply`, then switched on per request only for chat and the natural style.

## Shared data

```bash
cd .. && python3 -I scripts/export_dart.py
```

This rewrites `lib/core/generated.dart`, `assets/resep.md`, `assets/pengetahuan.md`, and `test/fixtures/`.

## Tests

```bash
flutter analyze
flutter test
MEIRA_ORT_LIB=<libonnxruntime.so for your laptop> MEIRA_HOME=~/MEIRA flutter test test/vision_test.dart
MEIRA_LIVE=1 MEIRA_HOME=~/MEIRA flutter test test/answer_eval_test.dart
```

| File | What it checks | Runs in CI |
|---|---|---|
| `core_test.dart` | vocabulary lookup, marker numbering and counting units, recipe ranking and request rules, removal of wrong marker references | yes |
| `quality_test.dart` | the quality gates shared with `scripts/eval_suite.py`: request understanding, recipe retrieval, guardrails, kitchen-note routing, and the check that rejects invented facts | yes |
| `vision_test.dart` | package OCR gives the same lines as the Python version and turns them into markers; the detector finds the labelled ingredient in a test photo | OCR yes; the detector needs MEIRA-Before data |
| `answer_eval_test.dart` | answers from the real language model, scored for grounding | no, needs `MEIRA_LIVE=1` and the model |
| `pipeline_live_test.dart` | a full turn with the real models | no, needs `MEIRA_LIVE=1` and the models |
| `chat_live_test.dart` | chat with the knowledge base; `MEIRA_LORA` loads the adapter, `MEIRA_TEST_ASK` replaces the questions (separated by `\|`) | no, needs `MEIRA_LIVE=1` and the model |
| `photo_live_test.dart` | an ingredient photo outside the detector's classes, such as dragon fruit, with the real detector and vision model | no, needs `MEIRA_LIVE=1`, `MEIRA_TEST_PHOTO`, and `MEIRA_ORT_LIB` |
| `screens_render_test.dart` | renders the home and Gizi Seimbang screens to PNG files in `MEIRA_SHOTS` for review | no, needs `MEIRA_SHOTS` |
| `tools_test.dart` | feature commands in chat (body data, weight, meal log, fasting, opening features) and nutrition label parsing | yes |
| `ocr_live_test.dart` | package and nutrition label OCR on real photos, including the zoomed second pass | no, needs `MEIRA_ORT_LIB` and `MEIRA_TEST_PHOTOS` |

The vision test needs an ONNX Runtime library for your laptop, for example from the Python `onnxruntime` package.
No test plays any sound.

## Continuous integration

`.github/workflows/ci.yml` runs on every push to `main` and on every pull request. It checks formatting with
`dart format -l 150`, runs `flutter analyze`, installs ONNX Runtime from pip for the OCR test, runs `flutter test`,
and checks that the scripts in `tool/` still parse.

## Emulator

```bash
emulator -avd <name> -no-audio -no-window -gpu swiftshader_indirect
tool/deploy_emulator.sh            # build, reinstall, and copy the downloaded models from MEIRA-Before
tool/record_demo.sh                # record the demo: name, photo from the gallery, recipe, follow-up question
python3 tool/make_gif.py build/demo docs/img/demo.gif
```

`deploy_emulator.sh` pushes the language model and Whisper to `/sdcard/Android/data/id.meira.meira/files/models/`
and opens their permissions, so the setup screen is skipped. `record_demo.sh` types slowly so the typing is visible
in the recording, and `make_gif.py` speeds up only the waiting parts. Processing on the emulator is much slower than
on an arm64 phone, and a software-rendered emulator can stutter on the first frames after launch.

## Release

```bash
flutter build apk --release --split-per-abi --target-platform android-arm64   # light APK, models are downloaded
tool/build_full_apk.sh                                                         # full APK with every model inside
```

The light APK (about 120 MB) downloads the language model and Whisper during setup or installs them from files. The
full APK (about 1.2 GB) carries them as uncompressed assets; on first launch the app copies them into its model folder
through `copyAsset` in `MainActivity.kt`, so a single file is enough to install. The phone then needs about 2.5 GB of
free space, because the APK and the copied models both stay on the device. The script links the models from
`MEIRA-Before/models/app` only for the build, and `.gitignore` keeps them out of the repository.

Commit messages follow Conventional Commits, for example `feat(chat): ...`, `fix(vision): ...`, or `docs: ...`.
