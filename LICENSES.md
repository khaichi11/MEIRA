# Third-party licenses · Lisensi pihak ketiga

[English](#english) · [Bahasa Indonesia](#bahasa-indonesia)

## English

The MEIRA app code is licensed under Apache-2.0 (see `LICENSE`). The recipe book, kitchen notes, and logo are
CC0 1.0. Illustrations and animations are drawn in code and are part of the app code.

### Models inside the APK

| Model | Role | License |
|---|---|---|
| MEIRA detector, D-FINE small fine-tuned from `ustc-community/dfine-small-coco` | ingredient markers | Apache-2.0 |
| PP-OCRv5 mobile detection and Latin recognition (PaddleOCR), converted to ONNX | package text | Apache-2.0 |

The detector was trained on Open Images V7 and LVIS v1 annotations (CC BY 4.0) with photos under licenses that allow
redistribution; photos under CC BY-SA were removed. Per-photo credits are in the
[MEIRA-Before](https://github.com/khaichi11/MEIRA-Before) repository.

### Models downloaded during setup

| Model | Role | License |
|---|---|---|
| Qwen3.5-0.8B instruct, GGUF | conversation and finished dishes | Apache-2.0 |
| Whisper small int8, sherpa-onnx export | speech to text | MIT |

### Libraries

| Package | License |
|---|---|
| Flutter, ffi, http, shared_preferences, path_provider, image_picker, record | BSD-3-Clause |
| sqflite, sqflite_common_ffi | BSD-2-Clause |
| flutter_tts, file_picker, archive | MIT |
| sherpa_onnx | Apache-2.0 |
| espeak-ng (bundled inside sherpa-onnx) | GPL-3.0 |
| ONNX Runtime 1.30.0 (`libonnxruntime.so`) | MIT |
| ONNX Runtime Dart bindings from `onnxruntime_flutter` 1.4.1 by gtbluesky, in `lib/third_party/` | MIT |
| llama.cpp (`llama-server`, packaged as `libllama_server.so`) | MIT |
| Poppins and Inter fonts | SIL OFL 1.1 |

Spoken answers use the phone's own Android TTS engine through `flutter_tts`; that engine belongs to the device and
is not distributed with the app. Because sherpa-onnx bundles espeak-ng, a distributed APK falls under GPL-3.0, which
requires the source code to be available. MEIRA's code is open under Apache-2.0, which can be combined into a GPL-3.0
work.

## Bahasa Indonesia

Kode aplikasi MEIRA berlisensi Apache-2.0 (lihat `LICENSE`). Buku resep, catatan dapur, dan logo berlisensi CC0 1.0.
Ilustrasi dan animasi digambar dengan kode dan termasuk kode aplikasi.

### Model di dalam APK

| Model | Peran | Lisensi |
|---|---|---|
| Detektor MEIRA, D-FINE small hasil fine-tune dari `ustc-community/dfine-small-coco` | penanda bahan | Apache-2.0 |
| PP-OCRv5 mobile untuk deteksi dan pengenalan huruf Latin (PaddleOCR), dikonversi ke ONNX | tulisan kemasan | Apache-2.0 |

Detektor dilatih dengan anotasi Open Images V7 dan LVIS v1 (CC BY 4.0) serta foto berlisensi yang boleh dibagikan
ulang; foto berlisensi CC BY-SA sudah dibuang. Atribusi setiap foto ada di repo
[MEIRA-Before](https://github.com/khaichi11/MEIRA-Before).

### Model yang diunduh saat penyiapan

| Model | Peran | Lisensi |
|---|---|---|
| Qwen3.5-0.8B instruct, GGUF | percakapan dan makanan jadi | Apache-2.0 |
| Whisper small int8, ekspor sherpa-onnx | ucapan menjadi teks | MIT |

### Pustaka

| Paket | Lisensi |
|---|---|
| Flutter, ffi, http, shared_preferences, path_provider, image_picker, record | BSD-3-Clause |
| sqflite, sqflite_common_ffi | BSD-2-Clause |
| flutter_tts, file_picker, archive | MIT |
| sherpa_onnx | Apache-2.0 |
| espeak-ng (ikut di dalam sherpa-onnx) | GPL-3.0 |
| ONNX Runtime 1.30.0 (`libonnxruntime.so`) | MIT |
| Binding Dart ONNX Runtime dari `onnxruntime_flutter` 1.4.1 karya gtbluesky, di `lib/third_party/` | MIT |
| llama.cpp (`llama-server`, dikemas sebagai `libllama_server.so`) | MIT |
| Font Poppins dan Inter | SIL OFL 1.1 |

Jawaban lisan memakai mesin TTS bawaan Android lewat `flutter_tts`; mesin itu milik perangkat dan tidak ikut dibagikan
bersama aplikasi. Karena sherpa-onnx menyertakan espeak-ng, APK yang dibagikan tunduk pada GPL-3.0, yang mewajibkan
kode sumbernya tersedia. Kode MEIRA terbuka dengan Apache-2.0, yang dapat digabungkan ke dalam karya GPL-3.0.
