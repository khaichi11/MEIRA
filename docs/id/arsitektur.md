# Arsitektur aplikasi

[English](../en/architecture.md)

Aplikasi ditulis dengan Flutter untuk Android. Semua model berjalan di ponsel: detektor bahan dan OCR lewat ONNX
Runtime, model bahasa lewat `llama-server` dari llama.cpp yang dijalankan sebagai proses lokal, dan Whisper lewat
sherpa-onnx.

## Susunan kode

```
lib/
  main.dart            titik masuk; animasi pembuka, penyiapan model, nama panggilan, lalu beranda
  app_state.dart       keadaan aplikasi: pengaturan, model, sesi, riwayat, persiapan foto untuk model
  core/
    pipeline.dart      satu giliran: foto, penanda, pemahaman permintaan, pemilihan jawaban
    grounding.dart     penanda: penggabungan kotak kembar, penomoran, satuan hitung
    recipes.dart       buku resep, peringkat, aturan pemahaman permintaan
    vocab.dart         kosakata bahan dan merek kemasan
    history.dart       riwayat SQLite dengan batas ukuran
    generated.dart     data bersama dari repo MEIRA-Before (jangan disunting manual)
  vision/
    detector.dart      detektor bahan D-FINE (ONNX)
    ocr.dart           OCR kemasan PP-OCRv5 (ONNX)
    ort.dart           pembungkus ONNX Runtime lewat FFI
    vision.dart        isolate yang menjalankan detektor dan OCR
  llm/
    memory.dart        memori percakapan dengan ringkasan
    retriever.dart     pencarian resep BM25
    knowledge.dart     catatan dapur (BM25) dan fakta makanan Wikidata dan USDA
    chain.dart         rantai jawaban dengan lanjutan otomatis
    guardrails.dart    pemeriksaan masukan dan keluaran
  runtime/
    llama.dart         pengelola llama-server dan klien HTTP-nya
    speech.dart        Whisper dan TTS bawaan ponsel
    models.dart        daftar model, unduhan, dan pemasangan dari berkas
  ui/                  pembuka, beranda, layar percakapan, resep, mode memasak, riwayat, dataset, pengaturan
assets/models/         detektor, OCR, dan adaptor LoRA obrolan yang dibawa di dalam APK
assets/pengetahuan_luas.jsonl  fakta makanan untuk obrolan (Wikidata CC0 dan USDA, domain publik)
```

## Layar

| Layar | Isi |
|---|---|
| Pembuka | "Halo!" muncul huruf demi huruf di layar putih, lingkaran hijau melebar menutupnya, lalu layar hijau membuka lubang bundar kecil, wajan muncul di dalamnya, dan lubang melebar hingga layar putih selama model dimuat |
| Nama panggilan | wajan memudar dan kotak hijau turun dari atas membawa sapaan; ditanyakan sekali dan hanya disimpan di ponsel. Setelah nama diisi, lembar putih naik dan beranda langsung tampil |
| Dapur (beranda) | sapaan, kolom tanya, tombol kamera dan galeri, jejak masak berbentuk kotak-kotak harian, kartu Gizi Seimbang dengan pilihan "Enak" atau "Enak & sehat", dan pintasan buku resep; panah kecil yang naik turun menandakan beranda bisa digulir |
| Buku resep | semua resep dengan pencarian nama atau bahan dan saringan (sehat, cepat, sarapan, tanpa kompor, minuman, berkuah) |
| Gizi Seimbang | tujuan (menuju berat badan ideal, menjaga berat badan, makan lebih seimbang), rencana makan hari ini yang bisa diganti per slot, capaian tujuh hari terakhir, serta pedoman Isi Piringku dan batas gula, garam, dan lemak dari Kementerian Kesehatan |
| Percakapan | foto berpenanda, kartu resep, jawaban, saran pertanyaan, kolom tanya; tanpa bilah navigasi, dengan tombol kembali |
| Resep | bahan dengan tanda tersedia, langkah, mode memasak dengan pengatur waktu, tombol bacakan yang sekaligus menjadi tombol hentikan suara, dan tanda "Sudah saya masak" |
| Riwayat, Dataset, Pengaturan | tab di bilah navigasi bawah |

![Layar aplikasi](../img/tampilan.jpg)

## Satu giliran percakapan

1. **Penanda.** Foto diubah ke 640 x 640 piksel dan diperiksa detektor di isolate tersendiri. Kotak di atas
   ambang menjadi penanda bernomor.
2. **Kemasan.** OCR membaca tulisan kemasan; baris yang menyebut bahan atau merek dikenal menjadi penanda.
3. **Foto tambahan.** Tombol tambah foto di layar percakapan menambah bahan dari foto lain tanpa mengganti foto
   utama.
4. **Pengaman masukan.** `Guardrails.checkInput` menolak upaya mengubah instruksi, permintaan berbahaya,
   pertanyaan medis, dan pesan di luar topik. Permintaan lanjutan seperti "cara membuatnya" selalu diteruskan.
5. **Pemahaman permintaan.** `ruleIntent` menentukan jenis permintaan dan isiannya.
6. **Jawaban.** Resep diambil dari buku resep. Pada gaya natural, Qwen3.5-0.8B menulis ulang jawaban resep menjadi
   kalimat lisan, dan tulisan ulang itu dipakai hanya bila `naturalMatches` lolos: semua nama resep, nomor penanda,
   dan angka tetap ada, tidak ada bahan atau angka baru, bahan yang perlu disiapkan tidak berubah menjadi bahan yang
   sudah ada, dan resep alternatif tetap disebut sebagai alternatif. Pertanyaan tentang makanan, misalnya beda
   rendang dan kalio, dijawab model dari fakta: catatan dapur yang judulnya cocok, ditambah fakta Wikidata dan USDA
   untuk setiap makanan yang disebut namanya. Tanpa fakta, MEIRA mengaku belum punya informasi pasti. Bahan yang
   disebut lewat ketikan diakui di awal jawaban, dan jawaban pertama dibuka dengan nama panggilan pengguna.
7. **Bahan di luar kelas detektor.** Bila detektor tidak mengenali bahan, misalnya buah naga, tebakan model
   penglihatan diterjemahkan lewat nama Inggris di basis pengetahuan lalu disebut sebagai dugaan beserta
   keterangannya. Bila tebakan itu bahan di buku resep, bahan tersebut dipakai untuk mencari resep.
8. **Gizi Seimbang.** Pada pilihan "Enak & sehat", atau bila permintaan menyebut sehat, diet, atau berat badan,
   resep yang lebih ringan didahulukan (`core/health.dart`: banyak sayur dan buah, lauk rendah lemak, dikukus atau
   direbus) dan jawaban resep diberi satu saran agar lebih ringan. Sebutan tentang berat badan dalam jawaban model
   diganti dengan istilah yang sopan, dan kondisi medis tetap diarahkan ke dokter atau ahli gizi.
9. **Memori.** Giliran lama diringkas bila melewati 700 token.

## Gerak

Animasi dibuat singkat dan lembut agar aplikasi terasa tenang: rangkaian pembuka, perpindahan tab yang memudar, baris
resep yang masuk bergantian, kartu yang sedikit mengecil saat ditekan, penanda bernomor yang muncul memantul, sapuan
cahaya di atas foto selama foto dibaca, dan jawaban yang muncul kata demi kata. Pembuka digerakkan oleh jam yang
membatasi lompatan tiap bingkai, sehingga saat aplikasi pertama kali dibuka dan ponsel sempat tersendat, gerakan
berhenti sejenak lalu berlanjut, bukan melompat ke akhir.

## Pengelolaan sumber daya

- Detektor dan OCR dimuat sekali di isolate saat foto pertama diproses.
- `llama-server` dapat dilepas saat aplikasi ditinggal lebih dari tiga menit.
- Whisper dimuat saat mikrofon dipakai dan dilepas setelah dua menit tidak aktif.
- Riwayat dibatasi 200 sesi dan 300 MB foto; yang paling lama dihapus lebih dulu.

## Data dan privasi

Semua data tersimpan di folder aplikasi: riwayat, foto, pengaturan, nama panggilan, jejak masak, tujuan Gizi Seimbang, dan model. Internet hanya
dipakai untuk mengunduh model saat penyiapan, dan langkah itu bisa dilewati dengan memasang model dari berkas.
