# MEIRA

**Multimodal Edge Intelligence for Recipe Assistance.** MEIRA adalah asisten dapur yang berjalan sepenuhnya di
ponsel Android. Anda cukup memotret bahan atau makanan jadi. MEIRA memberi nomor pada setiap bahan yang benar-benar
terlihat, lalu menyarankan resep dari buku resep di perangkat. Percakapan dapat dilanjutkan lewat ketikan atau
suara, misalnya "yang lain dong", "tanpa kompor", "maksimal 10 menit", atau "ada telur nggak?".

![MEIRA](assets/icon.png)

## Fitur

- **Penanda bernomor** di tengah setiap bahan, satu buah satu penanda. Penanda muncul bertahap selagi model membaca
  foto, dan nomor yang keliru dapat diketuk untuk diperbaiki.
- **Dua jenis foto.** Foto bahan menghasilkan saran resep; foto makanan jadi menghasilkan perkiraan nama hidangan
  beserta bahannya.
- **Kemasan dikenali**, misalnya mi instan, minyak goreng, dan kecap.
- **Percakapan** multi-giliran lewat teks atau suara, termasuk mode memasak dengan pengatur waktu per langkah.
- **Jawaban berpijak pada sumber.** Resep dan langkah diambil dari buku resep, dan pertanyaan seputar dapur dijawab
  dari catatan dapur yang ditulis tangan.
- **Pengaman percakapan** yang menolak permintaan berbahaya atau di luar topik dengan sopan.
- **Riwayat** tersimpan di perangkat dengan batas ukuran otomatis.
- **Dataset**: foto dan koreksi penanda dapat diekspor sebagai zip untuk pelatihan berikutnya.
- **Tanpa internet** setelah model diunduh. Tidak ada data yang dikirim keluar.

## Model

| Peran | Model | Runtime | Ukuran |
|---|---|---|---:|
| Mata | Qwen3.5-0.8B-Base hasil fine-tune MEIRA | llama.cpp (`llama-server` di dalam APK) | 0,7 GB |
| Otak | Qwen3.5-0.8B instruct | llama.cpp | 0,7 GB |
| Telinga | Whisper small int8 | sherpa-onnx | 0,4 GB |
| Suara | mesin TTS Android; Piper bahasa Indonesia sebagai pilihan | sistem atau sherpa-onnx | 0 atau 21 MB |

Data, pelatihan, dan evaluasi model ada di repo [MEIRA-Before](https://github.com/khaichi11/MEIRA-Before).

## Kebutuhan

- Android 9 atau lebih baru, prosesor arm64, RAM minimal 6 GB (disarankan 8 GB).
- Ruang kosong sekitar 2 GB untuk model.

## Build dan uji

```bash
flutter pub get
tool/build_native.sh            # kompilasi llama-server untuk Android, memerlukan Android NDK
flutter build apk --release
flutter test                    # uji unit dan gerbang mutu
```

Penjelasan lebih lengkap ada di [docs/arsitektur.md](docs/arsitektur.md) dan
[docs/pengembangan.md](docs/pengembangan.md).

## Lisensi

Kode berlisensi Apache-2.0, sedangkan logo, buku resep, dan catatan dapur berlisensi CC0. Lisensi model dan pustaka
pihak ketiga tercantum di [LICENSES.md](LICENSES.md) dan di menu Pengaturan > Lisensi.
