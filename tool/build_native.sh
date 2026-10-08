#!/usr/bin/env bash
# Kompilasi llama-server (llama.cpp) untuk Android, ambil ONNX Runtime resmi, lalu salin ke jniLibs.
#   ANDROID_NDK=~/Android/Sdk/ndk/29.0.14206865 tool/build_native.sh
# Hasil: android/app/src/main/jniLibs/{arm64-v8a,x86_64}/ (libllama_server.so dijalankan sebagai proses).
set -euo pipefail
cd "$(dirname "$0")/.."

LLAMA_TAG="${LLAMA_TAG:-b11476}"
NDK="${ANDROID_NDK:-$(ls -d "$HOME"/Android/Sdk/ndk/* | sort -V | tail -1)}"
CMAKE="${CMAKE:-$(ls -d "$HOME"/Android/Sdk/cmake/*/bin 2>/dev/null | sort -V | tail -1)/cmake}"
WORK="${WORK:-build/native}"
STRIP="$NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-strip"

mkdir -p "$WORK"
if [ ! -d "$WORK/llama.cpp" ]; then
  curl -fL "https://github.com/ggml-org/llama.cpp/archive/refs/tags/$LLAMA_TAG.tar.gz" | tar -xz -C "$WORK"
  mv "$WORK/llama.cpp-$LLAMA_TAG" "$WORK/llama.cpp"
fi

for ABI in arm64-v8a x86_64; do
  B="$WORK/build-$ABI"
  "$CMAKE" -S "$WORK/llama.cpp" -B "$B" -G Ninja \
    -DCMAKE_TOOLCHAIN_FILE="$NDK/build/cmake/android.toolchain.cmake" -DANDROID_ABI="$ABI" -DANDROID_PLATFORM=android-28 \
    -DANDROID_STL=c++_shared -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON \
    -DGGML_BACKEND_DL=ON -DGGML_CPU_ALL_VARIANTS=ON -DGGML_OPENMP=OFF -DGGML_NATIVE=OFF -DLLAMA_OPENSSL=OFF \
    -DLLAMA_BUILD_TESTS=OFF -DLLAMA_BUILD_EXAMPLES=OFF -DLLAMA_BUILD_TOOLS=ON -DLLAMA_BUILD_SERVER=ON
  "$CMAKE" --build "$B" --target llama-server -j"$(nproc)"
  OUT="android/app/src/main/jniLibs/$ABI"
  mkdir -p "$OUT"
  for f in "$B"/bin/*.so; do "$STRIP" --strip-unneeded -o "$OUT/$(basename "$f")" "$f"; done
  "$STRIP" --strip-unneeded -o "$OUT/libllama_server.so" "$B/bin/llama-server"
  TRIPLE=$([ "$ABI" = arm64-v8a ] && echo aarch64-linux-android || echo x86_64-linux-android)
  cp "$NDK/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/$TRIPLE/libc++_shared.so" "$OUT/"
done
# ONNX Runtime lengkap (Maven resmi, MIT) untuk detektor bahan dan OCR. Versi bawaan sherpa-onnx dipangkas dan
# tidak memuat semua operator yang dibutuhkan detektor; berkas ini menggantikannya saat pengemasan (pickFirst).
ORT_VERSION="${ORT_VERSION:-1.30.0}"
AAR="$WORK/onnxruntime-android-$ORT_VERSION.aar"
[ -f "$AAR" ] || curl -fL -o "$AAR" "https://repo1.maven.org/maven2/com/microsoft/onnxruntime/onnxruntime-android/$ORT_VERSION/onnxruntime-android-$ORT_VERSION.aar"
for ABI in arm64-v8a x86_64; do
  unzip -o -q -j "$AAR" "jni/$ABI/libonnxruntime.so" -d "android/app/src/main/jniLibs/$ABI"
done
echo "selesai: android/app/src/main/jniLibs"
