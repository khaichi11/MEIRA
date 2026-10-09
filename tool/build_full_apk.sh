#!/usr/bin/env bash
# APK lengkap untuk ponsel arm64: model bahasa dan Whisper ikut di dalam APK, sehingga cukup satu berkas untuk dipasang.
# Saat pertama dibuka, aplikasi menyalin model itu ke folder modelnya (perlu ruang kosong sekitar 2,5 GB di ponsel).
# Model diambil dari MEIRA-Before/models/app lewat hard link dan dilepas lagi setelah build, jadi tidak masuk git.
# Hasil: build/app/outputs/flutter-apk/meira-lengkap-arm64.apk
set -euo pipefail
cd "$(dirname "$0")/.."
MODELS="${MEIRA_HOME:-..}/models/app"
FILES=(qwen3.5-0.8b-instruct-Q4_K_M.gguf qwen3.5-0.8b-instruct-mmproj-F16.gguf
       whisper-small-encoder.int8.onnx whisper-small-decoder.int8.onnx whisper-small-tokens.txt)
cleanup() { for f in "${FILES[@]}"; do rm -f "assets/models/$f"; done; }
trap cleanup EXIT
for f in "${FILES[@]}"; do ln -f "$MODELS/$f" "assets/models/$f" 2>/dev/null || cp "$MODELS/$f" "assets/models/$f"; done
nice -n 10 flutter build apk --release --split-per-abi --target-platform android-arm64
mv build/app/outputs/flutter-apk/app-arm64-v8a-release.apk build/app/outputs/flutter-apk/meira-lengkap-arm64.apk
ls -la build/app/outputs/flutter-apk/meira-lengkap-arm64.apk
