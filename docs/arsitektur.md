# Arsitektur aplikasi

Aplikasi ditulis dengan Flutter untuk Android. Semua model berjalan di perangkat: model bahasa lewat `llama-server`
dari llama.cpp yang dijalankan sebagai proses lokal, dan model ucapan lewat sherpa-onnx.

## Susunan kode

```
lib/
  main.dart            titik masuk, tema, dan perpindahan splash, penyiapan, perkenalan, beranda
  app_state.dart       keadaan aplikasi: pengaturan, model aktif, sesi, riwayat
  core/
    pipeline.dart      alur satu giliran: foto, deteksi, pemahaman permintaan, pemilihan jawaban
    grounding.dart     pembaca keluaran model mata, penggabungan kotak, penomoran
    recipes.dart       pembaca buku resep, pemeringkatan, aturan pemahaman permintaan
    vocab.dart         kosakata bahan dan satuan hitung
    history.dart       riwayat SQLite dengan batas ukuran
    generated.dart     data bersama dari repo MEIRA-Before (jangan disunting manual)
  llm/
    memory.dart        memori percakapan dengan ringkasan
    retriever.dart     pencarian resep BM25
    knowledge.dart     pencarian catatan dapur BM25
    chain.dart         rantai jawaban dengan lanjutan otomatis
    guardrails.dart    pemeriksaan masukan dan keluaran
  runtime/
    llama.dart         pengelola proses llama-server dan klien HTTP-nya
    speech.dart        Whisper (ucapan ke teks) dan TTS
    models.dart        daftar model, unduhan, dan pemasangan dari berkas
    device.dart        informasi perangkat dan folder library native
  ui/                  layar dan komponen antarmuka
```

## Satu giliran percakapan

`Meira.turn` di `core/pipeline.dart` menerima foto, teks, atau keduanya, lalu mengalirkan peristiwa ke antarmuka:

1. **Deteksi.** Foto dikirim ke model mata. Setiap baris yang selesai dibaca langsung menjadi `PartialEvent`
   sehingga penanda muncul satu per satu.
2. **Pengaman masukan.** `Guardrails.checkInput` memeriksa upaya mengubah instruksi, permintaan berbahaya,
   pertanyaan medis, dan pesan di luar topik dapur. Pesan yang ditolak dijawab dengan kalimat sopan yang sudah
   disiapkan.
3. **Pemahaman permintaan.** `ruleIntent` menentukan jenis permintaan dan isian seperti batas waktu, bahan yang
   dihindari, atau nomor pilihan. Model otak hanya dimintai pendapat bila aturan tidak menemukan apa pun dan
   kalimatnya cukup panjang.
4. **Jawaban.** Ada empat jalur:
   - resep: templat dari buku resep, ditambah satu kalimat pembuka dari otak pada gaya natural;
   - catatan dapur: isi catatan yang paling cocok untuk pertanyaan seperti lama merebus telur;
   - cek bahan: dijawab dari daftar penanda dan diverifikasi ulang oleh model mata;
   - bebas: otak menjawab dengan konteks resep dan catatan, lalu jawabannya diperiksa.
5. **Pengaman keluaran.** `Guardrails.checkOutput` membuang bocoran nama bagian konteks dan tanda pisah panjang,
   menambahkan catatan keamanan pangan bila perlu, dan menolak definisi yang berputar.
6. **Memori.** Giliran disimpan di `ConversationMemory`. Bila melebihi anggaran token, giliran lama diringkas.

## Pengelolaan sumber daya

- `llama-server` untuk mata dan otak dijalankan sesuai kebutuhan dan dapat dilepas saat aplikasi masuk latar
  belakang.
- Whisper dimuat di isolate terpisah saat mikrofon pertama kali dipakai, lalu dilepas setelah dua menit tidak aktif.
- Foto untuk model diperkecil ke sisi 512 piksel (dapat diatur). Foto asli di riwayat dibatasi 300 MB dan sesi
  dibatasi 200; yang paling lama dihapus lebih dulu.
- Jumlah thread inferensi mengikuti jumlah inti prosesor, paling banyak empat.

## Data dan privasi

Semua data tersimpan di folder aplikasi: riwayat SQLite, foto, pengaturan, dan model. Aplikasi hanya memakai
internet untuk mengunduh model saat penyiapan, dan langkah itu dapat dilewati dengan memasang model dari berkas.
