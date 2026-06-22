"""Genera ilustraciones planas estilizadas para cada departamento.

Estilo: escena geometrica plana sobre cielo calido degradado, paleta del tema
(crema / terracota / rosa polvo / dorado) con acentos muted. Salida cuadrada
512px (supersampling 2x) en assets/departments/{id}.png.

Uso:  py tool/generate_department_art.py
"""

import math
import os

from PIL import Image, ImageDraw, ImageFilter

# --- Paleta del tema + acentos muted ---
CREAM = (0xFA, 0xF4, 0xEC)
SURFACE = (0xFF, 0xFD, 0xF9)
SURFACE_DIM = (0xF1, 0xE7, 0xDA)
TERRACOTTA = (0xBC, 0x6B, 0x4C)
TERRACOTTA_DARK = (0x9A, 0x52, 0x38)
DUSTY_ROSE = (0xD7, 0xA9, 0xA1)
GOLD = (0xC9, 0xA2, 0x4B)
INK = (0x3D, 0x2C, 0x26)
WHITE = (0xFF, 0xFD, 0xF9)

# Acentos naturales muted (armonizan con la paleta calida)
SKY_TOP = (0xF7, 0xEC, 0xDF)
SKY_BOT = (0xEED, 0xD0, 0xC9) if False else (0xED, 0xD0, 0xC9)
OLIVE = (0x8B, 0x9B, 0x6E)
OLIVE_DEEP = (0x6E, 0x7E, 0x54)
TEAL = (0x9F, 0xB8, 0xB4)
TEAL_DEEP = (0x7E, 0x9B, 0x96)
MAUVE = (0x9C, 0x77, 0x90)
SAND = (0xE3, 0xC9, 0xA8)

S = 2
SIZE = 512
BIG = SIZE * S

ROOT = os.path.normpath(os.path.join(os.path.dirname(__file__), ".."))
OUT_DIR = os.path.join(ROOT, "assets", "departments")


def lerp(a, b, t):
    return tuple(round(a[i] + (b[i] - a[i]) * t) for i in range(3))


def base_canvas(top=SKY_TOP, bot=SKY_BOT):
    img = Image.new("RGB", (BIG, BIG))
    px = img.load()
    for y in range(BIG):
        c = lerp(top, bot, y / (BIG - 1))
        for x in range(BIG):
            px[x, y] = c
    return img


def sun(draw, cx, cy, r, color=GOLD):
    draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=color)


def ground(draw, y, color):
    draw.rectangle([0, y, BIG, BIG], fill=color)


def soft_shadow(img, drawer):
    """Aplica una sombra difusa de la silueta dibujada por `drawer`."""
    sh = Image.new("RGBA", (BIG, BIG), (0, 0, 0, 0))
    d = ImageDraw.Draw(sh)
    drawer(d)
    sh = sh.filter(ImageFilter.GaussianBlur(6 * S))
    img.paste((0, 0, 0), (0, 0), sh)


# ---------------- Escenas por departamento ----------------

def la_paz(img, d):
    # Illimani nevado + cabina de teleferico.
    ground(d, int(BIG * 0.72), SURFACE_DIM)
    # Cordillera de fondo (rosa polvo).
    d.polygon([(0, BIG * 0.72), (BIG * 0.30, BIG * 0.40),
               (BIG * 0.60, BIG * 0.72)], fill=DUSTY_ROSE)
    # Illimani (terracota) con tres cumbres.
    peak = [(BIG * 0.35, BIG * 0.72), (BIG * 0.58, BIG * 0.30),
            (BIG * 0.72, BIG * 0.46), (BIG * 0.82, BIG * 0.34),
            (BIG * 1.05, BIG * 0.72)]
    d.polygon(peak, fill=TERRACOTTA)
    # Nieve en las cumbres.
    d.polygon([(BIG * 0.52, BIG * 0.39), (BIG * 0.58, BIG * 0.30),
               (BIG * 0.64, BIG * 0.39), (BIG * 0.58, BIG * 0.43)], fill=WHITE)
    d.polygon([(BIG * 0.76, BIG * 0.40), (BIG * 0.82, BIG * 0.34),
               (BIG * 0.88, BIG * 0.40), (BIG * 0.82, BIG * 0.44)], fill=WHITE)
    # Linea + cabina de teleferico.
    d.line([(BIG * 0.08, BIG * 0.22), (BIG * 0.95, BIG * 0.40)],
           fill=INK, width=3 * S)
    cx, cy = BIG * 0.34, BIG * 0.34
    d.rounded_rectangle([cx - 16 * S, cy, cx + 16 * S, cy + 26 * S],
                        radius=6 * S, fill=GOLD, outline=TERRACOTTA_DARK,
                        width=2 * S)
    d.line([(cx, BIG * 0.285), (cx, cy)], fill=INK, width=2 * S)


def cochabamba(img, d):
    # Cristo de la Concordia sobre la colina.
    ground(d, int(BIG * 0.70), OLIVE)
    d.ellipse([BIG * 0.18, BIG * 0.58, BIG * 0.82, BIG * 0.95], fill=OLIVE_DEEP)
    sun(d, BIG * 0.78, BIG * 0.22, 34 * S, color=GOLD)
    # Figura del Cristo (silueta) brazos abiertos.
    cx = BIG * 0.5
    top = BIG * 0.28
    d.line([(cx, top), (cx, BIG * 0.62)], fill=WHITE, width=10 * S)   # cuerpo
    d.line([(BIG * 0.34, BIG * 0.40), (BIG * 0.66, BIG * 0.40)],
           fill=WHITE, width=10 * S)                                  # brazos
    d.ellipse([cx - 9 * S, top - 16 * S, cx + 9 * S, top + 2 * S], fill=WHITE)  # cabeza


def santa_cruz(img, d):
    # Palmeras + sol tropical.
    ground(d, int(BIG * 0.74), SAND)
    sun(d, BIG * 0.72, BIG * 0.26, 40 * S, color=GOLD)

    def palm(px, py, h, lean=0):
        d.line([(px, py), (px + lean, py - h)], fill=TERRACOTTA_DARK,
               width=9 * S)
        tx, ty = px + lean, py - h
        for ang in (-150, -110, -70, -30, -190, 10):
            ex = tx + math.cos(math.radians(ang)) * 70 * S
            ey = ty + math.sin(math.radians(ang)) * 70 * S
            d.line([(tx, ty), (ex, ey)], fill=OLIVE_DEEP, width=7 * S)

    palm(BIG * 0.40, BIG * 0.74, BIG * 0.40, lean=-10 * S)
    palm(BIG * 0.60, BIG * 0.74, BIG * 0.30, lean=14 * S)


def oruro(img, d):
    # Mascara de la Diablada.
    cx, cy = BIG * 0.5, BIG * 0.56
    # Cuernos.
    d.polygon([(BIG * 0.30, BIG * 0.40), (BIG * 0.20, BIG * 0.16),
               (BIG * 0.40, BIG * 0.34)], fill=GOLD)
    d.polygon([(BIG * 0.70, BIG * 0.40), (BIG * 0.80, BIG * 0.16),
               (BIG * 0.60, BIG * 0.34)], fill=GOLD)
    # Cara.
    d.ellipse([BIG * 0.28, BIG * 0.30, BIG * 0.72, BIG * 0.82], fill=TERRACOTTA)
    d.ellipse([BIG * 0.28, BIG * 0.30, BIG * 0.72, BIG * 0.82], outline=TERRACOTTA_DARK, width=3 * S)
    # Ojos.
    d.ellipse([BIG * 0.38, BIG * 0.46, BIG * 0.46, BIG * 0.54], fill=WHITE)
    d.ellipse([BIG * 0.54, BIG * 0.46, BIG * 0.62, BIG * 0.54], fill=WHITE)
    d.ellipse([BIG * 0.405, BIG * 0.485, BIG * 0.435, BIG * 0.515], fill=INK)
    d.ellipse([BIG * 0.565, BIG * 0.485, BIG * 0.595, BIG * 0.515], fill=INK)
    # Sonrisa con dientes.
    d.arc([BIG * 0.40, BIG * 0.56, BIG * 0.60, BIG * 0.74], 10, 170,
          fill=WHITE, width=7 * S)


def potosi(img, d):
    # Cerro Rico conico con bocamina.
    ground(d, int(BIG * 0.74), SAND)
    sun(d, BIG * 0.24, BIG * 0.24, 30 * S, color=DUSTY_ROSE)
    d.polygon([(BIG * 0.18, BIG * 0.74), (BIG * 0.5, BIG * 0.20),
               (BIG * 0.82, BIG * 0.74)], fill=TERRACOTTA)
    d.polygon([(BIG * 0.18, BIG * 0.74), (BIG * 0.5, BIG * 0.20),
               (BIG * 0.5, BIG * 0.74)], fill=TERRACOTTA_DARK)
    # Vetas.
    d.line([(BIG * 0.5, BIG * 0.30), (BIG * 0.40, BIG * 0.60)], fill=GOLD, width=3 * S)
    d.line([(BIG * 0.5, BIG * 0.34), (BIG * 0.60, BIG * 0.58)], fill=GOLD, width=3 * S)
    # Bocamina.
    d.pieslice([BIG * 0.44, BIG * 0.66, BIG * 0.56, BIG * 0.84], 180, 360, fill=INK)
    d.rectangle([BIG * 0.44, BIG * 0.74, BIG * 0.56, BIG * 0.79], fill=INK)


def chuquisaca(img, d):
    # Fachada colonial blanca (Sucre, la ciudad blanca) + campanario.
    ground(d, int(BIG * 0.78), SURFACE_DIM)
    sun(d, BIG * 0.80, BIG * 0.22, 26 * S, color=GOLD)
    # Edificio principal.
    d.rectangle([BIG * 0.22, BIG * 0.42, BIG * 0.70, BIG * 0.78], fill=WHITE,
                outline=SURFACE_DIM, width=2 * S)
    # Torre/campanario.
    d.rectangle([BIG * 0.62, BIG * 0.26, BIG * 0.78, BIG * 0.78], fill=WHITE,
                outline=SURFACE_DIM, width=2 * S)
    d.polygon([(BIG * 0.62, BIG * 0.26), (BIG * 0.70, BIG * 0.16),
               (BIG * 0.78, BIG * 0.26)], fill=TERRACOTTA)
    d.line([(BIG * 0.70, BIG * 0.16), (BIG * 0.70, BIG * 0.10)], fill=INK, width=3 * S)
    d.line([(BIG * 0.665, BIG * 0.125), (BIG * 0.735, BIG * 0.125)], fill=INK, width=3 * S)
    # Arcos.
    for i in range(3):
        x0 = BIG * (0.26 + i * 0.14)
        d.pieslice([x0, BIG * 0.54, x0 + BIG * 0.10, BIG * 0.74], 180, 360,
                   fill=TERRACOTTA)
        d.rectangle([x0, BIG * 0.64, x0 + BIG * 0.10, BIG * 0.78], fill=TERRACOTTA)


def tarija(img, d):
    # Racimo de uvas + hoja (vinedos).
    sun(d, BIG * 0.22, BIG * 0.24, 30 * S, color=GOLD)
    # Hoja.
    d.polygon([(BIG * 0.55, BIG * 0.22), (BIG * 0.74, BIG * 0.20),
               (BIG * 0.68, BIG * 0.40), (BIG * 0.52, BIG * 0.36)], fill=OLIVE_DEEP)
    # Tallo.
    d.line([(BIG * 0.5, BIG * 0.24), (BIG * 0.5, BIG * 0.40)], fill=OLIVE_DEEP, width=4 * S)
    # Racimo (triangulo de circulos).
    r = 26 * S
    rows = [(0.5,), (0.42, 0.58), (0.34, 0.5, 0.66), (0.42, 0.58), (0.5,)]
    for ri, xs in enumerate(rows):
        cy = BIG * (0.44 + ri * 0.105)
        for xf in xs:
            cx = BIG * xf
            d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=MAUVE,
                      outline=INK, width=2 * S)


def beni(img, d):
    # Rio amazonico serpenteante + sol + juncos.
    ground(d, int(BIG * 0.50), OLIVE)
    sun(d, BIG * 0.74, BIG * 0.24, 36 * S, color=GOLD)
    # Rio (banda curva teal).
    river = Image.new("RGBA", (BIG, BIG), (0, 0, 0, 0))
    rd = ImageDraw.Draw(river)
    pts = [(BIG * 0.0, BIG * 0.60), (BIG * 0.3, BIG * 0.66),
           (BIG * 0.5, BIG * 0.78), (BIG * 0.75, BIG * 0.70),
           (BIG * 1.0, BIG * 0.86)]
    rd.line(pts, fill=TEAL, width=46 * S, joint="curve")
    img.paste(Image.new("RGB", (BIG, BIG), TEAL), (0, 0), river)
    # Juncos.
    for x in (0.18, 0.24, 0.30):
        d.line([(BIG * x, BIG * 0.58), (BIG * x, BIG * 0.40)], fill=OLIVE_DEEP, width=4 * S)


def pando(img, d):
    # Arbol de castana de copa frondosa (selva).
    ground(d, int(BIG * 0.76), OLIVE)
    sun(d, BIG * 0.78, BIG * 0.24, 28 * S, color=GOLD)
    # Tronco.
    d.rectangle([BIG * 0.47, BIG * 0.48, BIG * 0.53, BIG * 0.78], fill=TERRACOTTA_DARK)
    # Copa (tres circulos verdes).
    for cx, cy, r in [(0.50, 0.36, 0.20), (0.38, 0.44, 0.14), (0.62, 0.44, 0.14)]:
        d.ellipse([BIG * (cx - r), BIG * (cy - r), BIG * (cx + r), BIG * (cy + r)],
                  fill=OLIVE_DEEP)
    d.ellipse([BIG * 0.34, BIG * 0.26, BIG * 0.66, BIG * 0.50], fill=OLIVE)


SCENES = {
    "la_paz": la_paz,
    "cochabamba": cochabamba,
    "santa_cruz": santa_cruz,
    "oruro": oruro,
    "potosi": potosi,
    "chuquisaca": chuquisaca,
    "tarija": tarija,
    "beni": beni,
    "pando": pando,
}


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    for dept_id, scene in SCENES.items():
        img = base_canvas().convert("RGB")
        draw = ImageDraw.Draw(img)
        scene(img, draw)
        img.resize((SIZE, SIZE), Image.LANCZOS).save(
            os.path.join(OUT_DIR, f"{dept_id}.png"))
        print("ok", dept_id)
    print("Ilustraciones generadas en", OUT_DIR)


if __name__ == "__main__":
    main()
