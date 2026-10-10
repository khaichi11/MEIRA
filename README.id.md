<p align="center"><img src="docs/img/logo.png" alt="MEIRA logo" width="110"></p>

# MEIRA

Multimodal Edge Intelligence for Recipe Assistance: asisten dapur dan gizi luring untuk Android. Potret bahan di
dapur Anda, lalu MEIRA memberi nomor pada setiap bahan, membaca tulisan kemasan, dan menyarankan resep dari buku resep
di ponsel. MEIRA juga menyimpan catatan makan, berat badan, dan jadwal puasa Anda, dan menjawab lewat ketikan atau
suara.

[English](README.md)

<p align="center"><img src="docs/img/demo.gif" width="300" alt="Demo: pembuka, beranda dengan jejak masak, foto bahan dengan penanda bernomor dan resep, obrolan gizi, Gizi Seimbang, buku resep, dan tur"></p>

![Beranda, foto bahan, obrolan gizi, Gizi Seimbang, dan buku resep](docs/img/tampilan.jpg)

## Fitur

- Setiap bahan di foto mendapat penanda bernomor sendiri. Bila ada yang keliru, ketik nama yang benar, misalnya
  "ini buah naga".
- Tulisan kemasan seperti mi instan dan kecap manis dibaca dengan OCR. Foto bagian Informasi Nilai Gizi memberi nilai
  per sajian dan per kemasan, saran porsi, dan perbandingannya dengan kebutuhan harian Anda.
- Pertanyaan tentang makanan, misalnya beda rendang dan kalio, dijawab dari catatan dapur, Wikidata, dan USDA, dan
  MEIRA berterus terang bila belum punya informasi pasti.
- Gizi Seimbang: kalkulator tubuh (IMT, berat badan ideal, kebutuhan dan batas harian), catatan makan, progres berat,
  puasa berselang dengan pengingat, dan rencana makan dari resep yang lebih ringan.
- Asisten memakai fitur itu langsung: "berat saya 70 kg", "tadi pagi saya makan nasi goreng", atau "boleh makan
  sekarang?" dicatat atau dijawab dari data Anda sendiri, disertai tombol untuk membuka fiturnya.
- Jejak masak di beranda terisi setiap hari Anda menyelesaikan resep.
- Mode memasak menampilkan langkah satu per satu; pengatur waktu dimulai dengan ketukan atau perintah suara dan
  memberi pemberitahuan saat selesai.
- Buku resep berisi 285 resep, termasuk hidangan populer seperti soto ayam, rawon, pempek, dan klepon, dengan pencarian dan saringan, dan pilihan "Enak & sehat" mendahulukan resep
  yang lebih ringan.
- Setelah model diunduh, aplikasi tidak memerlukan internet dan tidak ada data yang keluar dari ponsel.

## Model

| Peran | Model | Sumber | Runtime | Ukuran |
|---|---|---|---|---:|
| Penanda bahan | D-FINE small | dilatih untuk MEIRA di MEIRA-Before | ONNX Runtime | 42 MB, di dalam APK |
| Pembaca kemasan | PP-OCRv5 mobile | PaddleOCR, dipakai apa adanya | ONNX Runtime | 13 MB, di dalam APK |
| Percakapan dan makanan jadi | Qwen3.5-0.8B instruct | [unsloth/Qwen3.5-0.8B-GGUF](https://huggingface.co/unsloth/Qwen3.5-0.8B-GGUF), dipakai apa adanya | llama.cpp | 0,7 GB, diunduh sekali |
| Ucapan menjadi teks | Whisper small int8 | [csukuangfj/sherpa-onnx-whisper-small](https://huggingface.co/csukuangfj/sherpa-onnx-whisper-small), dipakai apa adanya | sherpa-onnx | 0,4 GB, diunduh sekali |
| Suara | mesin TTS ponsel | Android | Android | |

Model yang diunduh berasal dari repositori Hugging Face publik di atas, bukan dari akun MEIRA. APK lengkap yang dibuat
dengan `tool/build_full_apk.sh` membawa berkas yang sama, sehingga tidak ada yang perlu diunduh.

Penanda bahan masih terus diperbaiki; hasil terkini dan kekurangannya ada di
[evaluasi MEIRA-Before](https://github.com/khaichi11/MEIRA-Before/blob/main/docs/id/evaluasi.md).

## Teknologi

| Lapisan | Alat |
|---|---|
| Aplikasi | Flutter 3.41, Dart 3.11, Material 3, font Inter dan Poppins |
| Inferensi di ponsel | ONNX Runtime 1.30 lewat FFI untuk detektor dan OCR, `llama-server` dari llama.cpp untuk model bahasa, sherpa-onnx untuk Whisper |
| Pencarian | BM25 atas buku resep dan catatan dapur, ditambah pencarian nama atas 4.085 fakta makanan Wikidata (CC0) dan USDA (domain publik) |
| Penyimpanan | SQLite (sqflite) dan shared_preferences |
| Platform | Android 9 atau lebih baru; suara lewat mesin TTS ponsel (flutter_tts) |
| Perkakas | flutter test, dart format, ffmpeg dan Pillow untuk gambar demo |

Dua model di-fine-tune untuk aplikasi ini: detektor bahan (D-FINE small, 132 kelas dari foto Open Images, LVIS, dan Wikimedia Commons) dan
adaptor LoRA obrolan sebesar 22 MB untuk Qwen3.5-0.8B instruct yang menjawab pertanyaan makanan hanya dari fakta yang
diberikan dan menulis ulang jawaban buku resep pada gaya natural. Pada pertanyaan yang disisihkan, adaptor ini
menaikkan akurasi jawaban berbasis fakta dari 0,67 menjadi 0,96. Model lain dipakai apa adanya. Mata VLM dan kandidat
otak tetap menjadi latihan riset: detektor terbukti lebih akurat dan lebih cepat daripada mata VLM. Daftar seluruh latihan ada
di [MEIRA-Before](https://github.com/khaichi11/MEIRA-Before/blob/main/README.id.md#model-hasil-fine-tune).

## Kebutuhan

- Android 9 atau lebih baru, arm64, RAM minimal 6 GB (disarankan 8 GB).
- Ruang kosong sekitar 1,2 GB untuk model yang diunduh, atau sekitar 2,5 GB untuk APK lengkap yang sudah memuat
  model.

## Build dan uji

```bash
flutter pub get
tool/build_native.sh            # llama-server dan ONNX Runtime untuk Android, memerlukan Android NDK
flutter build apk --release
flutter test
```

## Dokumentasi

| Bahasa Indonesia | English |
|---|---|
| [Arsitektur](docs/id/arsitektur.md) | [Architecture](docs/en/architecture.md) |
| [Pengembangan](docs/id/pengembangan.md) | [Development](docs/en/development.md) |
| [Lisensi](LICENSES.md) | [Licenses](LICENSES.md) |

Data, pelatihan, dan evaluasi ada di [MEIRA-Before](https://github.com/khaichi11/MEIRA-Before).

## Lisensi

Kode berlisensi Apache-2.0. Logo, buku resep, dan catatan dapur berlisensi CC0. Model dan pustaka pihak ketiga
tercantum di [LICENSES.md](LICENSES.md) dan di menu Pengaturan > Lisensi.
