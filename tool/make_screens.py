"""Susun beberapa tangkapan layar menjadi satu gambar dokumentasi, masing-masing di dalam bingkai ponsel generik.

    python3 tool/make_screens.py docs/img/tampilan.jpg pembuka.png nama.png dapur.png ...
"""

import sys
from pathlib import Path

from PIL import Image, ImageFilter

sys.path.insert(0, str(Path(__file__).resolve().parent))
from phone_frame import phone  # noqa: E402

BG = (238, 243, 248)  # sama dengan warna latar berkelompok di aplikasi
WIDTH = 330  # lebar layar tiap ponsel
GAP, PAD = 28, 40


def main(out: str, *screens: str) -> None:
    phones = []
    for f in screens:
        im = Image.open(f).convert("RGB")
        phones.append(phone(im.resize((WIDTH, round(im.height * WIDTH / im.width)), Image.LANCZOS)))
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
    main(*sys.argv[1:])
