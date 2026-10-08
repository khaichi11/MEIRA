# Panduan pengembangan

## Persiapan

- Flutter 3.41 atau lebih baru dengan Dart 3.11.
- Android SDK dengan NDK dan CMake (diatur lewat Android Studio atau `sdkmanager`).
- Repo [MEIRA-Before](https://github.com/khaichi11/MEIRA-Before) di folder induk bila ingin memperbarui data
  bersama atau menjalankan uji dengan model sungguhan.

## llama-server untuk Android

Aplikasi menjalankan `llama-server` sebagai proses terpisah. Berkasnya dikemas sebagai `libllama_server.so` di
`android/app/src/main/jniLibs/<ABI>/`, karena Android hanya mengizinkan eksekusi dari folder library native.

```bash
ANDROID_NDK=~/Android/Sdk/ndk/<versi> tool/build_native.sh
```

Skrip ini mengunduh llama.cpp versi `b11476`, mengompilasinya untuk arm64-v8a dan x86_64, lalu menyalin hasilnya.
`GGML_CPU_ALL_VARIANTS` membuat beberapa varian CPU sekaligus, dan llama.cpp memilih varian tercepat yang didukung
ponsel saat berjalan. `useLegacyPackaging` di `build.gradle.kts` memastikan library diekstrak ke disk sehingga bisa
dieksekusi.

## Data bersama

Kosakata, satuan hitung, prompt, buku resep aktif, catatan dapur, dan data uji berasal dari repo MEIRA-Before:

```bash
cd ../ && python3 -I scripts/export_dart.py
```

Perintah ini menulis ulang `lib/core/generated.dart`, `assets/resep.md`, `assets/pengetahuan.md`, dan
`test/fixtures/`. Berkas tersebut tidak disunting manual.

## Uji

```bash
flutter analyze
flutter test test/core_test.dart test/quality_test.dart
```

`quality_test.dart` memakai gerbang mutu yang sama dengan `scripts/eval_suite.py`: pemahaman permintaan pada set
pengembangan dan set terpisah, pencarian resep, pengaman percakapan, pencarian catatan dapur, dan pemeriksaan
jawaban yang mengarang. Hasilnya ditulis ke `../runs/eval/` agar ikut masuk laporan evaluasi.

Uji dengan model sungguhan memerlukan model di `MEIRA_HOME/models/app` dan `llama-server` di
`MEIRA_HOME/external/llama.cpp`:

```bash
MEIRA_LIVE=1 MEIRA_HOME=~/MEIRA flutter test test/pipeline_live_test.dart
MEIRA_LIVE=1 MEIRA_HOME=~/MEIRA flutter test test/answer_eval_test.dart
```

Untuk membandingkan model otak, jalankan uji jawaban dengan `MEIRA_BRAIN=<berkas gguf>` dan
`MEIRA_OUT=<folder hasil>` untuk setiap kandidat, lalu `.venv-train/bin/python scripts/compare_brains.py runs/brains/*` di repo
MEIRA-Before. Uji ini tidak memutar suara apa pun.

## Emulator

Emulator x86_64 dapat dipakai untuk memeriksa antarmuka. Jalankan dengan `-no-audio` bila tidak ingin ada suara.
Inferensi di emulator jauh lebih lambat daripada di ponsel arm64, sehingga angka waktu sebaiknya diukur di perangkat
sungguhan.

## Rilis

```bash
flutter build apk --release --split-per-abi
```

Pesan commit mengikuti Conventional Commits, misalnya `feat(chat): ...`, `fix(grounding): ...`, atau
`docs: ...`.
