"""Susun beberapa tangkapan layar menjadi satu gambar dokumentasi, masing-masing di dalam bingkai ponsel generik.

    python3 tool/make_screens.py docs/img/tampilan.jpg pembuka.png nama.png dapur.png ...

Untuk bingkai dari test/demo_render_test.dart (layar dengan ruang bilah status dan garis gestur yang masih kosong),
tambahkan --demo: jam, sinyal, baterai, dan garis gestur digambar di ruang itu.
"""

import sys
from pathlib import Path

from PIL import Image, ImageFilter

sys.path.insert(0, str(Path(__file__).resolve().parent))
from phone_frame import phone, system_bars  # noqa: E402

BG = (238, 243, 248)  # sama dengan warna latar berkelompok di aplikasi
WIDTH = 330  # lebar layar tiap ponsel
GAP, PAD = 28, 40


def main(out: str, *screens: str, demo: bool = False) -> None:
    phones = []
    for f in screens:
        im = Image.open(f).convert("RGB")
        if demo:
            im = system_bars(im, round(24 * im.width / 360), round(16 * im.width / 360))
        im = im.resize((WIDTH, round(im.height * WIDTH / im.width)), Image.LANCZOS)
        phones.append(phone(im, status_bar=None if demo else True))
    pw, ph = phones[0].size
    sheet = Image.new("RGBA", (PAD * 2 + len(phones) * pw + (len(phones) - 1) * GAP, PAD * 2 + ph), BG + (255,))
    for i, p in enumerate(phones):
        x = PAD + i * (pw + GAP)
        # bayangan lembut di bawah ponsel
        shadow = Image.new("RGBA", p.size, (30, 42, 68, 0))
        shadow.putalpha(p.getchannel("A").point(lambda v: v * 50 // 255))
        sheet.alpha_composite(shadow.filter(ImageFilter.GaussianBlur(10)), (x, PAD + 10))
        sheet.alpha_composite(p, (x, PAD))
    sheet.convert("RGB").save(out, quality=88, optimize=True)
    print(f"{out}: {sheet.width}x{sheet.height}")


if __name__ == "__main__":
    args = [a for a in sys.argv[1:] if a != "--demo"]
    main(*args, demo="--demo" in sys.argv)
