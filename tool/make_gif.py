"""Susun GIF demo dari rekaman tool/record_demo.sh, di dalam bingkai ponsel generik.

Bagian mengetik dan animasi tetap berkecepatan asli; bagian menunggu (membaca foto di emulator) dipercepat
supaya GIF tetap singkat tanpa membuat ketikan terlihat terburu-buru.

    python3 tool/make_gif.py build/demo docs/img/demo.gif
"""

import json
import subprocess
import sys
from pathlib import Path

from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent))
from phone_frame import layout, overlay, status_shift  # noqa: E402

# kecepatan tiap bagian, dari tanda awal sampai tanda berikutnya
SPEED = {"wait_photo": 4.0, "detected": 4.0}
OFFSET = 1.0  # rekaman layar dimulai satu detik sebelum tanda "start"
INTRO = 4.0  # detik pertama setelah aplikasi dibuka: animasi pembuka
BG = "0xEEF3F8"  # sama dengan latar gambar tampilan aplikasi
MARGIN = 18


def video_size(path: Path) -> tuple[int, int]:
    info = subprocess.run(
        ["ffprobe", "-v", "error", "-select_streams", "v:0", "-show_entries", "stream=width,height", "-of", "json", str(path)],
        capture_output=True, text=True, check=True,
    )
    s = json.loads(info.stdout)["streams"][0]
    return s["width"], s["height"]


def first_green(path: Path, limit: float = 8.0) -> float:
    """Detik pertama layar berwarna hijau pembuka, supaya GIF mulai di dalam aplikasi, bukan di layar beranda ponsel."""
    raw = subprocess.run(
        ["ffmpeg", "-loglevel", "error", "-t", str(limit), "-i", str(path), "-vf", "fps=20,scale=4:8", "-f", "rawvideo", "-pix_fmt", "rgb24", "-"],
        capture_output=True, check=True,
    ).stdout
    size = 4 * 8 * 3
    for i in range(len(raw) // size):
        frame = raw[i * size:(i + 1) * size]
        r, g, b = frame[(4 * 4 + 2) * 3:(4 * 4 + 2) * 3 + 3]  # piksel tengah
        if g > 140 and r < 90 and b > 100:
            return i / 20
    return 0.0


def main(folder: str, out: str, width: int = 300, fps: int = 10) -> None:
    root = Path(folder)
    marks = [line.split(maxsplit=1) for line in (root / "marks.txt").read_text().splitlines() if line.strip()]
    times = [(int(ms) / 1000 + OFFSET, name.strip()) for ms, name in marks]
    # buang bagian sebelum aplikasi tampil (layar beranda ponsel saat ikon diketuk)
    times[0] = (max(times[0][0], first_green(root / "demo.mp4")), times[0][1])
    parts = []
    for (a, name), (b, _) in zip(times, times[1:]):
        if name == "start" and b - a > INTRO + 1:
            # animasi pembuka tetap utuh, sisa waktu memuat model dipercepat
            parts += [(a, a + INTRO, 1.0), (a + INTRO, b, 2.5)]
        else:
            parts.append((a, b, 3.0 if name.startswith("wait_") else SPEED.get(name, 1.0)))

    vw, vh = video_size(root / "demo.mp4")
    w, h = width, round(vh * width / vw / 2) * 2  # tinggi genap, syarat format warna video
    g = layout(w, h)
    bar, m = status_shift(w, h)
    canvas = (g["size"][0] + 2 * MARGIN, g["size"][1] + 2 * MARGIN)
    frame = Image.new("RGBA", canvas, (0, 0, 0, 0))
    frame.alpha_composite(overlay(w, h), (MARGIN, MARGIN))
    frame_png = root / "bingkai.png"
    frame.save(frame_png)
    sx, sy = MARGIN + g["screen"][0], MARGIN + g["screen"][1]

    # Diproses bertahap supaya ringan: setiap potongan dipotong dan dikecilkan sendiri-sendiri, lalu disambung,
    # diberi bingkai, dan palet warnanya dibuat di lintasan terpisah. Cara satu filter besar menahan seluruh video
    # di memori dan membuat laptop kehabisan RAM.
    tmp = root / "gif-tmp"
    tmp.mkdir(exist_ok=True)
    ff = ["nice", "-n", "10", "ffmpeg", "-loglevel", "error", "-y", "-threads", "2"]
    small = ["-c:v", "libx264", "-preset", "veryfast", "-crf", "16", "-pix_fmt", "yuv444p", "-an"]
    listing = []
    for i, (a, b, k) in enumerate(parts):
        seg = tmp / f"potong_{i:02d}.mp4"
        vf = f"setpts=(PTS-STARTPTS)/{k},fps={fps},scale={w}:{h}:flags=lanczos"
        subprocess.run([*ff, "-ss", f"{a:.3f}", "-to", f"{b:.3f}", "-i", str(root / "demo.mp4"), "-vf", vf, *small, str(seg)], check=True)
        listing.append(f"file '{seg.name}'")
    (tmp / "daftar.txt").write_text("\n".join(listing) + "\n")
    joined = tmp / "gabung.mp4"
    subprocess.run([*ff, "-f", "concat", "-safe", "0", "-i", str(tmp / "daftar.txt"), "-c", "copy", str(joined)], check=True)

    half = w // 2
    graph = ";".join([
        # dua piksel terluar rekaman sering berisi garis warna sisa; diganti baris atau kolom di dalamnya
        "[0:v]format=rgb24,split=5[raw][t][bt][lf][rt]",
        f"[t]crop={w}:1:0:2,scale={w}:2[t2]",
        f"[bt]crop={w}:1:0:{h - 3},scale={w}:2[b2]",
        f"[lf]crop=1:{h}:2:0,scale=2:{h}[l2]",
        f"[rt]crop=1:{h}:{w - 3}:0,scale=2:{h}[r2]",
        "[raw][t2]overlay=0:0:format=rgb[x1]",
        f"[x1][b2]overlay=0:{h - 2}:format=rgb[x2]",
        "[x2][l2]overlay=0:0:format=rgb[x3]",
        f"[x3][r2]overlay={w - 2}:0:format=rgb,split=4[b0][l][r][c]",
        # jam dan ikon bilah status digeser ke tengah agar tidak terpotong sudut bingkai
        f"[l]crop={half}:{bar}:0:0[lh]",
        f"[r]crop={w - half}:{bar}:{half}:0[rh]",
        f"[c]crop=1:{bar}:{half}:0,scale={m}:{bar},split[f1][f2]",
        f"[b0][lh]overlay={m}:0:format=rgb[b1]",
        f"[b1][rh]overlay={half - m}:0:format=rgb[b2]",
        "[b2][f1]overlay=0:0:format=rgb[b3]",
        f"[b3][f2]overlay={w - m}:0:format=rgb[scr]",
        f"color=c={BG}:s={canvas[0]}x{canvas[1]}:r={fps},format=rgb24[bg]",
        f"[bg][scr]overlay={sx}:{sy}:format=rgb:shortest=1[t]",
        "[t][1:v]overlay=0:0:format=rgb",
    ])
    framed = tmp / "bingkai.mp4"
    subprocess.run([*ff, "-i", str(joined), "-i", str(frame_png), "-filter_complex", graph, *small, str(framed)], check=True)
    palette = tmp / "palet.png"
    subprocess.run([*ff, "-i", str(framed), "-vf", "palettegen=stats_mode=diff", str(palette)], check=True)
    subprocess.run(
        [*ff, "-i", str(framed), "-i", str(palette), "-lavfi", "paletteuse=dither=bayer:bayer_scale=5:diff_mode=rectangle", out],
        check=True,
    )
    for f in tmp.iterdir():
        f.unlink()
    tmp.rmdir()
    total = sum((b - a) / k for a, b, k in parts)
    print(f"{out}: {total:.1f} detik, {canvas[0]}x{canvas[1]}, {Path(out).stat().st_size / 1e6:.1f} MB")


if __name__ == "__main__":
    main(*sys.argv[1:3])
