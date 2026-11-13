"""Draws the Mothakira launcher icon: a two-tone open book on deep teal.

Run from `student_app/`: it rewrites every Android density plus the adaptive
icon foreground. Sizes follow the platform rules: 48/72/96/144/192 for the
legacy icon, 108/162/216/324/432 (108dp) for the adaptive foreground.
"""

from PIL import Image, ImageDraw

BACKGROUND = (0x17, 0x3F, 0x48, 255)  # primaryLight
PAGE = (0xFF, 0xFE, 0xFA, 255)  # surfaceContainerLowest
ACCENT = (0x98, 0x5A, 0x3B, 255)  # accent

RES = "android/app/src/main/res"
LEGACY = {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}
FOREGROUND = {"mdpi": 108, "hdpi": 162, "xhdpi": 216, "xxhdpi": 324, "xxxhdpi": 432}
MASTER = 4096

LEFT_PAGE = [(232, 400), (492, 470), (492, 700), (232, 660)]
RIGHT_PAGE = [(532, 470), (792, 400), (792, 660), (532, 700)]


def glyph(size):
    layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    scale = size / 1024

    def shape(points):
        return [(x * scale, y * scale) for x, y in points]

    draw.polygon(shape(LEFT_PAGE), fill=PAGE)
    draw.polygon(shape(RIGHT_PAGE), fill=ACCENT)
    return layer


def legacy_tile(size):
    tile = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(tile)
    draw.rounded_rectangle([0, 0, size - 1, size - 1], radius=int(size * 0.22), fill=BACKGROUND)
    tile.alpha_composite(glyph(size))
    return tile


if __name__ == "__main__":
    master_tile = legacy_tile(MASTER)
    master_glyph = glyph(MASTER)

    for density, size in LEGACY.items():
        master_tile.resize((size, size), Image.LANCZOS).save(f"{RES}/mipmap-{density}/ic_launcher.png")
    for density, size in FOREGROUND.items():
        master_glyph.resize((size, size), Image.LANCZOS).save(f"{RES}/mipmap-{density}/ic_launcher_foreground.png")
    print("launcher icons written")
