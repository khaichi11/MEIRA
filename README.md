# MEIRA

**Multimodal Edge Intelligence for Recipe Assistance.** Asisten dapur yang berjalan sepenuhnya di HP Android:
foto bahan atau makanan jadi, MEIRA memberi nomor pada setiap bahan yang benar-benar terlihat, lalu mencarikan resep.
Tanyakan lanjut lewat ketikan atau suara: "yang lain dong", "tanpa kompor", "maksimal 10 menit", "ada telur nggak?".

![MEIRA](assets/icon.png)

## Fitur

- **Penanda angka** di tengah setiap bahan, satu buah satu penanda. Penanda muncul bertahap selagi model membaca foto.
- **Foto bahan** untuk rekomendasi resep, atau **foto makanan jadi** untuk mengetahui nama hidangan dan bahannya.
  Bahan yang terlihat bernomor, bahan tebakan diberi label "perkiraan".
- **Percakapan** multi-giliran lewat teks atau suara, termasuk mode percakapan suara tanpa menekan tombol.
- **Cek ulang**: "apakah ada wortel?" memicu verifikasi khusus di foto, bukan tebakan.
- **Riwayat** di perangkat (SQLite) dengan batas ukuran otomatis.
- **Dataset**: tandai bahan di dapurmu sendiri, ekspor sebagai zip untuk training berikutnya.
- **Offline**: model diunduh sekali, setelah itu tidak butuh internet. Tidak ada data yang dikirim keluar.

## Cara kerja

| Peran | Model | Runtime |
|---|---|---|
| Mata | Qwen3.5-0.8B-Base hasil fine-tune MEIRA | llama.cpp (`llama-server` di dalam APK) |
| Otak | Qwen3.5-0.8B instruct | llama.cpp |
| Telinga | Whisper base int8 | sherpa-onnx |
| Suara | Piper bahasa Indonesia int8 | sherpa-onnx |

Rekomendasi dan langkah memasak diambil langsung dari buku resep lokal (`assets/resep.md`), jadi instan dan tidak mengarang.
Model bahasa dipakai untuk pertanyaan bebas, penjelasan hidangan, dan memahami permintaan.
Dataset, training, dan evaluasi model mata ada di repo [MEIRA-Before](https://github.com/khaichi11/MEIRA-Before).

## Kebutuhan

- Android 9 atau lebih baru, arm64, RAM 6 GB atau lebih (disarankan 8 GB).
- Ruang kosong sekitar 2 GB untuk model.

## Build

```bash
flutter pub get
tool/build_native.sh            # kompilasi llama-server untuk Android (butuh Android NDK)
flutter build apk --release
```

Saat pertama dibuka, aplikasi menawarkan unduhan model (sekitar 0,9 GB, ditambah 0,7 GB untuk model mata),
atau pemasangan dari file yang sudah disalin ke HP.

Versi desktop Linux memakai kode yang sama: `flutter build linux`, dengan `llama-server` dari
`MEIRA_HOME/external/llama.cpp` dan model di `MEIRA_HOME/models/app`.

## Uji

```bash
flutter test test/core_test.dart
MEIRA_LIVE=1 MEIRA_HOME=~/MEIRA flutter test test/pipeline_live_test.dart   # memakai model sungguhan
```

## Lisensi

Kode Apache-2.0. Logo dan buku resep CC0. Model Qwen3.5 Apache-2.0, llama.cpp MIT, Whisper MIT, sherpa-onnx Apache-2.0,
suara Piper memakai espeak-ng (GPL-3.0), font Poppins dan Inter SIL OFL 1.1. Rincian ada di menu Pengaturan > Lisensi.
