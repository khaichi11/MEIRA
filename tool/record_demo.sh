#!/usr/bin/env bash
# Rekam demo singkat di emulator lalu ubah menjadi GIF untuk dokumentasi.
# Syarat: aplikasi baru dipasang (layar nama belum diisi), model sudah disalin dengan tool/deploy_emulator.sh,
# dan foto bahan ada di galeri (PHOTO_INDEX memilih urutannya). Hasil: build/demo/demo.mp4 dan marks.txt,
# lalu tool/make_gif.py menyusun GIF dengan bagian menunggu dipercepat.
set -euo pipefail
cd "$(dirname "$0")/.."
ADB="${ADB:-$HOME/Android/Sdk/platform-tools/adb}"
APP=id.meira.meira
OUT=build/demo
QUESTION="${QUESTION:-gimana cara bikinnya}"
mkdir -p "$OUT"; : > "$OUT/marks.txt"

# pusat elemen pertama yang teks atau content-desc-nya cocok dengan pola
center() {
  for _ in 1 2 3 4 5; do
    "$ADB" shell uiautomator dump /sdcard/ui.xml >/dev/null 2>&1 || { sleep 1; continue; }
    "$ADB" exec-out cat /sdcard/ui.xml | python3 -I -c '
import re, sys
pat, xml = re.compile(sys.argv[1]), sys.stdin.read()
for node in re.finditer(r"<node [^>]*>", xml):
    n = node.group(0)
    labels = re.findall(r"(?:text|content-desc|class)=\"([^\"]*)\"", n)
    if any(pat.search(v) for v in labels):
        x1, y1, x2, y2 = map(int, re.search(r"bounds=\"\[(\d+),(\d+)\]\[(\d+),(\d+)\]\"", n).groups())
        print((x1 + x2) // 2, (y1 + y2) // 2); break
else:
    sys.exit(1)' "$1" && return 0
    sleep 1
  done
  return 1
}
tap() { local p; p=$(center "$1") || { echo "tidak ketemu: $1" >&2; exit 1; }; "$ADB" shell input tap $p; }
# ketuk elemen ke-n (mulai dari 1) yang cocok dengan pola, misalnya foto kedua di pemilih foto
tap_nth() {
  local p
  "$ADB" shell uiautomator dump /sdcard/ui.xml >/dev/null 2>&1
  p=$("$ADB" exec-out cat /sdcard/ui.xml | python3 -I -c '
import re, sys
pat, n, xml = re.compile(sys.argv[1]), int(sys.argv[2]), sys.stdin.read()
hits = []
for node in re.finditer(r"<node [^>]*>", xml):
    v = node.group(0)
    if any(pat.search(x) for x in re.findall(r"(?:text|content-desc)=\"([^\"]*)\"", v)):
        hits.append(tuple(map(int, re.search(r"bounds=\"\[(\d+),(\d+)\]\[(\d+),(\d+)\]\"", v).groups())))
x1, y1, x2, y2 = hits[n - 1]
print((x1 + x2) // 2, (y1 + y2) // 2)' "$1" "$2") || { echo "tidak ketemu: $1 ke-$2" >&2; exit 1; }
  "$ADB" shell input tap $p
}
wait_for() { for _ in $(seq 1 "${2:-90}"); do center "$1" >/dev/null 2>&1 && return 0; sleep 1; done; echo "habis waktu: $1" >&2; exit 1; }
mark() { echo "$(( $(date +%s%N) / 1000000 - START )) $1" >> "$OUT/marks.txt"; }
type_slow() {  # ketik per huruf supaya terlihat di rekaman
  local s=$1 i c
  for (( i = 0; i < ${#s}; i++ )); do
    c=${s:i:1}; [[ $c == " " ]] && c=%s
    "$ADB" shell input text "$c"; sleep 0.12
  done
}

hide_kb() { "$ADB" shell dumpsys input_method | grep -q "mInputShown=true" && "$ADB" shell input keyevent 4 || true; }
# kirim pertanyaan, tunggu jawabannya selesai, lalu beri waktu membaca; tanda wait_* dipercepat di GIF
ask() {
  tap 'EditText'; sleep 0.6; mark "ask_$1"; type_slow "$2"; sleep 0.8
  "$ADB" shell input keyevent 66; sleep 0.6; hide_kb; mark "wait_$1"
  sleep 3; wait_for '^(Resep lain|Bahannya)' 300; mark "read_$1"; sleep "${3:-5}"
}
# screenrecord dibatasi 180 detik per berkas, jadi rekaman disambung beberapa berkas
record() {
  for i in 1 2 3 4 5; do
    [[ -f "$OUT/stop" ]] && break
    "$ADB" shell screenrecord --bit-rate 6000000 --time-limit 180 "/sdcard/demo_$i.mp4" || break
  done
}

"$ADB" shell am force-stop $APP
"$ADB" shell 'rm -f /sdcard/demo*.mp4'
rm -f "$OUT/stop" "$OUT"/demo_*.mp4
record & REC=$!
sleep 1; START=$(( $(date +%s%N) / 1000000 ))
"$ADB" shell am start -n $APP/.MainActivity >/dev/null
mark start
wait_for 'EditText' 120; mark name
tap 'EditText'; sleep 0.6; type_slow "${NAME:-Khai}"; sleep 0.8
"$ADB" shell input keyevent 111; sleep 0.4    # tutup papan ketik
tap '^Lanjut'; sleep 2.5; mark home
tap '^Galeri'; sleep 3; mark picker
tap_nth '^(Photo taken|Foto diambil)' "${PHOTO_INDEX:-2}"; sleep 1
tap '^(Done|Selesai)$'
mark wait_photo
wait_for 'Dibaca dalam' 300; mark detected
wait_for 'Rekomendasi' 300; mark answer_start
# saran pertanyaan baru muncul setelah jawaban selesai diproses
wait_for '^(Resep lain|Bahannya)' 300; sleep 5; mark answer_shown
ask cara "$QUESTION" 6
# tambah bahan lewat ketikan
ask telur "ada telur juga" 5
# pertanyaan bebas dijawab model bahasa di ponsel
ask bebas "apel hijau rasanya beda nggak sama apel merah" 7
# tambah bahan dari foto kedua
tap 'Tambah bahan dari foto'; sleep 1.5; mark tambah_foto
tap '^Galeri$'; sleep 3
tap_nth '^(Photo taken|Foto diambil)' 1; sleep 1
tap '^(Done|Selesai)$'; mark wait_foto2
sleep 3; wait_for '^(Resep lain|Bahannya)' 300; mark read_foto2; sleep 6
# kartu resep, rincian, dan mode memasak
for _ in 1 2 3 4; do "$ADB" shell input swipe 360 500 360 1400 250; done
sleep 1; tap 'Rekomendasi'; sleep 2.5; mark rincian
"$ADB" shell input swipe 360 1300 360 500 600; sleep 1.5
tap '^Mulai memasak$'; sleep 2.5; mark memasak
tap '^Langkah berikutnya$'; sleep 2.5
tap '^Langkah berikutnya$'; sleep 2.5
"$ADB" shell input keyevent 4; sleep 1.2; "$ADB" shell input keyevent 4; sleep 1.2
"$ADB" shell input keyevent 4; sleep 2; mark tab
# tab lain di beranda
tap '^Riwayat$'; sleep 2.5
tap '^Dataset$'; sleep 2.5
tap '^Pengaturan$'; sleep 2.5
tap '^Dapur$'; sleep 2.5; mark done
touch "$OUT/stop"; "$ADB" shell pkill -INT screenrecord || true; wait $REC 2>/dev/null || true; sleep 2
# gabungkan potongan rekaman menjadi satu video
: > "$OUT/daftar.txt"
for i in 1 2 3 4 5; do
  "$ADB" pull "/sdcard/demo_$i.mp4" "$OUT/demo_$i.mp4" >/dev/null 2>&1 || break
  echo "file 'demo_$i.mp4'" >> "$OUT/daftar.txt"
done
ffmpeg -loglevel error -y -f concat -safe 0 -i "$OUT/daftar.txt" -c copy "$OUT/demo.mp4"
rm -f "$OUT"/demo_*.mp4 "$OUT/daftar.txt" "$OUT/stop"; "$ADB" shell 'rm -f /sdcard/demo*.mp4'
cat "$OUT/marks.txt"
