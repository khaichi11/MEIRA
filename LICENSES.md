# Lisensi pihak ketiga

Kode aplikasi MEIRA berlisensi Apache-2.0 (lihat `LICENSE`). Buku resep, catatan dapur, dan logo: CC0 1.0.

## Model yang diunduh saat penyiapan
| Model | Lisensi |
|---|---|
| Qwen3.5-0.8B (otak) dan MEIRA eyes hasil fine-tune Qwen3.5-0.8B-Base (mata) | Apache-2.0 |
| Whisper small int8 (pengenal ucapan) | MIT |
| Suara Piper `id_ID-news_tts-medium` (opsional) | MIT untuk bobotnya; data latihnya tidak dicantumkan jelas |

Data latih model mata: anotasi Open Images V7 dan LVIS v1 (CC BY 4.0) dengan foto berlisensi bebas, rinciannya di
repo MEIRA-Before.

## Pustaka
| Paket | Lisensi |
|---|---|
| Flutter, http, shared_preferences, path_provider, image_picker | BSD-3-Clause |
| sqflite, sqflite_common_ffi | BSD-2-Clause |
| record | BSD-3-Clause |
| audioplayers | MIT |
| flutter_tts | MIT |
| file_picker | MIT |
| archive | MIT |
| sherpa_onnx | Apache-2.0 |
| espeak-ng (di dalam sherpa-onnx, untuk suara Piper) | GPL-3.0 |
| llama.cpp (`llama-server`, dikemas sebagai `libllama_server.so`) | MIT |
| Font Poppins, Inter | SIL OFL 1.1 |

Suara bawaan memakai mesin TTS sistem Android lewat `flutter_tts`; mesin tersebut milik perangkat dan tidak ikut
dibagikan bersama aplikasi. Karena paket sherpa-onnx menyertakan espeak-ng, APK yang dibagikan tunduk pada syarat
GPL-3.0, yaitu kode sumbernya harus tersedia. Kode MEIRA terbuka dengan Apache-2.0, yang dapat digabungkan ke dalam
karya GPL-3.0.
