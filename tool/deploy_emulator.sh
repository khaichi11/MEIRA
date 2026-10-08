#!/usr/bin/env bash
# Pasang APK rilis ke emulator atau ponsel yang terhubung, lalu salin model unduhan dari MEIRA-Before.
# Pemakaian: tool/deploy_emulator.sh [--no-build]
set -euo pipefail
cd "$(dirname "$0")/.."
ADB="${ADB:-$HOME/Android/Sdk/platform-tools/adb}"
MODELS="${MEIRA_HOME:-..}/models/app"
APP=id.meira.meira
DEST=/sdcard/Android/data/$APP/files/models

[[ " $* " == *" --no-build "* ]] || flutter build apk --release
"$ADB" wait-for-device
"$ADB" uninstall "$APP" >/dev/null 2>&1 || true
"$ADB" install -r build/app/outputs/flutter-apk/app-release.apk
"$ADB" shell mkdir -p "$DEST"
for f in qwen3.5-0.8b-instruct-Q4_K_M.gguf qwen3.5-0.8b-instruct-mmproj-F16.gguf \
         whisper-small-encoder.int8.onnx whisper-small-decoder.int8.onnx whisper-small-tokens.txt; do
  "$ADB" push "$MODELS/$f" "$DEST/$f" >/dev/null
done
"$ADB" shell chmod 777 "$DEST"
"$ADB" shell "chmod 666 $DEST/*"
echo "terpasang; jalankan dengan: $ADB shell am start -n $APP/.MainActivity"
