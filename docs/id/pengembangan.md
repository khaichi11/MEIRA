# Panduan pengembangan

[English](../en/development.md)

## Persiapan

- Flutter 3.41 atau lebih baru dengan Dart 3.11.
- Android SDK dengan NDK dan CMake.
- Repo [MEIRA-Before](https://github.com/khaichi11/MEIRA-Before) di folder induk bila ingin memperbarui data bersama
  atau menjalankan uji dengan model sungguhan.

## Pustaka native

```bash
ANDROID_NDK=~/Android/Sdk/ndk/<versi> tool/build_native.sh
```

Skrip ini mengompilasi `llama-server` dari llama.cpp `b11476` untuk arm64-v8a dan x86_64, lalu mengambil ONNX
Runtime 1.30.0 resmi dari Maven. Hasilnya disalin ke `android/app/src/main/jniLibs/`, yang tidak ikut disimpan di
git.

- `llama-server` dikemas sebagai `libllama_server.so` karena Android hanya mengizinkan eksekusi dari folder
  library native. `useLegacyPackaging` memastikan berkas diekstrak ke disk.
- ONNX Runtime lengkap dikemas sebagai `libonnxruntime_meira.so`, dengan SONAME yang diubah memakai `patchelf`, di
  samping `libonnxruntime.so` versi ringkas yang dibawa sherpa-onnx. Detektor memerlukan operator yang tidak ada di
  versi ringkas, sedangkan sherpa-onnx ditautkan ke simbol berversi milik versinya sendiri (`VERS_1.28.2`), sehingga
  Whisper hanya bisa dimuat dengan pustaka itu. Mengganti salah satunya dengan yang lain akan merusak detektor atau
  input suara.

## Model di dalam APK

`assets/models/` berisi detektor bahan dan OCR (sekitar 55 MB). Detektor diekspor dari repo MEIRA-Before:

```bash
.venv-train/bin/python scripts/export_detector.py --model runs/meira-det-small --name meira-det-small
.venv-train/bin/python scripts/eval_detector.py --onnx models/app/meira-det-small.onnx --model runs/meira-det-small \
    --name "MEIRA detektor small" --threads 4      # menulis ambang ke meira-det-small.json
```

Salin `meira-det-small.onnx`, `.labels.txt`, dan `.json` ke `assets/models/` dengan nama `meira-det.*`.

Adaptor LoRA obrolan (`meira-chat-lora-f16.gguf`, sekitar 22 MB) dilatih di MEIRA-Before dan disalin ke
`assets/models/`. Berkas ini tidak disimpan di git; bila tidak ada saat build, aplikasi tetap berjalan dengan model
dasar. Saat aplikasi dibuka, adaptor disalin ke folder model dan dipasang pada `llama-server` dengan
`--lora-init-without-apply`, lalu diaktifkan per permintaan hanya untuk obrolan dan gaya natural.

## Data bersama

```bash
cd .. && python3 -I scripts/export_dart.py
```

Perintah ini menulis ulang `lib/core/generated.dart`, `assets/resep.md`, `assets/pengetahuan.md`, dan
`test/fixtures/`.

## Uji

```bash
flutter analyze
flutter test
MEIRA_ORT_LIB=<libonnxruntime.so di laptop> MEIRA_HOME=~/MEIRA flutter test test/vision_test.dart
MEIRA_LIVE=1 MEIRA_HOME=~/MEIRA flutter test test/answer_eval_test.dart
```

| Berkas | Yang diperiksa | Jalan di CI |
|---|---|---|
| `core_test.dart` | pencarian kosakata, penomoran penanda dan satuan hitung, peringkat resep dan aturan permintaan, pembuangan rujukan nomor yang salah | ya |
| `quality_test.dart` | gerbang mutu yang sama dengan `scripts/eval_suite.py`: pemahaman permintaan, pencarian resep, pengaman, pengarahan ke catatan dapur, dan pemeriksaan yang menolak fakta karangan | ya |
| `vision_test.dart` | OCR kemasan menghasilkan baris yang sama dengan versi Python dan mengubahnya menjadi penanda; detektor menemukan bahan berlabel pada foto uji | OCR ya; detektor memerlukan data MEIRA-Before |
| `answer_eval_test.dart` | jawaban dari model bahasa sungguhan, dinilai keberpijakannya | tidak, perlu `MEIRA_LIVE=1` dan modelnya |
| `pipeline_live_test.dart` | satu giliran lengkap dengan model sungguhan | tidak, perlu `MEIRA_LIVE=1` dan modelnya |
| `chat_live_test.dart` | obrolan dengan basis pengetahuan; `MEIRA_LORA` memasang adaptor, `MEIRA_TEST_ASK` mengganti pertanyaan (dipisah `\|`) | tidak, perlu `MEIRA_LIVE=1` dan modelnya |
| `photo_live_test.dart` | foto bahan di luar kelas detektor, misalnya buah naga, dengan detektor dan model penglihatan sungguhan | tidak, perlu `MEIRA_LIVE=1`, `MEIRA_TEST_PHOTO`, dan `MEIRA_ORT_LIB` |
| `screens_render_test.dart` | menggambar beranda dan layar Gizi Seimbang ke PNG di folder `MEIRA_SHOTS` untuk diperiksa | tidak, perlu `MEIRA_SHOTS` |
| `tools_test.dart` | perintah fitur di obrolan (data tubuh, berat, catatan makan, puasa, membuka fitur) dan pembacaan label gizi | ya |
| `ocr_live_test.dart` | OCR kemasan dan label gizi pada foto sungguhan, termasuk pembacaan ulang yang diperbesar | tidak, perlu `MEIRA_ORT_LIB` dan `MEIRA_TEST_PHOTOS` |

Uji penglihatan memerlukan pustaka ONNX Runtime untuk laptop, misalnya dari paket Python `onnxruntime`. Tidak ada uji
yang memutar suara.

## Integrasi berkelanjutan

`.github/workflows/ci.yml` berjalan pada setiap push ke `main` dan setiap pull request. Alur ini memeriksa format
dengan `dart format -l 150`, menjalankan `flutter analyze`, memasang ONNX Runtime dari pip untuk uji OCR, menjalankan
`flutter test`, dan memastikan skrip di `tool/` masih bisa dibaca.

## Emulator

```bash
emulator -avd <nama> -no-audio -no-window -gpu swiftshader_indirect
tool/deploy_emulator.sh            # build, pasang ulang, dan salin model unduhan dari MEIRA-Before
tool/record_demo.sh                # rekam demo: nama, foto dari galeri, resep, pertanyaan lanjutan
python3 tool/make_gif.py build/demo docs/img/demo.gif
```

`deploy_emulator.sh` menyalin model bahasa dan Whisper ke `/sdcard/Android/data/id.meira.meira/files/models/` lalu
membuka izinnya, sehingga layar penyiapan terlewati. `record_demo.sh` mengetik perlahan agar ketikannya terlihat di
rekaman, dan `make_gif.py` hanya mempercepat bagian menunggu. Waktu proses di emulator jauh lebih lambat daripada di
ponsel arm64, dan emulator dengan render perangkat lunak bisa tersendat pada bingkai pertama setelah aplikasi dibuka.

## Rilis

```bash
flutter build apk --release --split-per-abi --target-platform android-arm64   # APK ringan, model diunduh
tool/build_full_apk.sh                                                         # APK lengkap, semua model di dalamnya
```

APK ringan (sekitar 120 MB) mengunduh model bahasa dan Whisper saat penyiapan atau memasangnya dari file. APK lengkap
(sekitar 1,2 GB) membawa model tersebut sebagai aset tanpa kompresi; saat pertama dibuka, aplikasi menyalinnya ke
folder model melalui `copyAsset` di `MainActivity.kt`, sehingga cukup satu berkas untuk dipasang. Ponsel kemudian
memerlukan ruang kosong sekitar 2,5 GB karena APK dan salinan modelnya sama-sama tersimpan. Skrip ini menautkan model
dari `MEIRA-Before/models/app` hanya selama build, dan `.gitignore` menjaga model agar tidak masuk ke repositori.

Pesan commit mengikuti Conventional Commits, misalnya `feat(chat): ...`, `fix(vision): ...`, atau `docs: ...`.
