"""Genera los íconos de "Our Journey" a partir de la paleta del tema.

Dibuja a 4x y reduce para antialias. Produce:
  assets/icon/app_icon.png            -> ícono completo (iOS / legacy)
  assets/icon/app_icon_foreground.png -> corazón centrado, fondo transparente
                                          (foreground del adaptive icon Android)

Motivo: corazón terracota sobre fondo crema cálido, con un camino punteado
dorado curvo detrás que evoca el "viaje" de la pareja.

Uso:  py tool/generate_icon.py
"""

import math
import os

from PIL import Image, ImageDraw

# --- Paleta (de lib/app/theme/app_colors.dart) ---
CREAM = (0xFA, 0xF4, 0xEC)
DUSTY_ROSE = (0xD7, 0xA9, 0xA1)
TERRACOTTA = (0xBC, 0x6B, 0x4C)
TERRACOTTA_DARK = (0x9A, 0x52, 0x38)
GOLD = (0xC9, 0xA2, 0x4B)

S = 4            # supersampling
SIZE = 1024
BIG = SIZE * S

ROOT = os.path.normpath(os.path.join(os.path.dirname(__file__), ".."))
OUT_DIR = os.path.join(ROOT, "assets", "icon")


def lerp(a, b, t):
    return tuple(round(a[i] + (b[i] - a[i]) * t) for i in range(3))


def vertical_gradient(size, top, bottom):
    img = Image.new("RGB", (size, size))
    px = img.load()
    for y in range(size):
        color = lerp(top, bottom, y / (size - 1))
        for x in range(size):
            px[x, y] = color
    return img


def heart_points(cx, cy, scale):
    """Curva de corazón parametrica, centrada en (cx, cy)."""
    pts = []
    steps = 720
    for i in range(steps + 1):
        t = math.pi * 2 * i / steps
        x = 16 * math.sin(t) ** 3
        y = 13 * math.cos(t) - 5 * math.cos(2 * t) - 2 * math.cos(3 * t) - math.cos(4 * t)
        pts.append((cx + x * scale, cy - y * scale))
    return pts


def draw_heart(draw, cx, cy, scale, fill, outline=None, width=0):
    draw.polygon(heart_points(cx, cy, scale), fill=fill, outline=outline)
    if outline and width:
        draw.line(heart_points(cx, cy, scale) + [heart_points(cx, cy, scale)[0]],
                  fill=outline, width=width, joint="curve")


def draw_journey_path(draw, cx, cy, scale):
    """Camino punteado dorado curvo detrás del corazon."""
    r = scale * 13.5
    dot_r = scale * 0.7
    # Arco de ~210deg desde abajo-izq hasta arriba-der.
    start, end = 150, -40
    n = 22
    for i in range(n):
        ang = math.radians(start + (end - start) * i / (n - 1))
        x = cx + r * math.cos(ang)
        y = cy - r * math.sin(ang) * 0.92
        draw.ellipse([x - dot_r, y - dot_r, x + dot_r, y + dot_r], fill=GOLD)


def build_full():
    img = vertical_gradient(BIG, CREAM, DUSTY_ROSE).convert("RGBA")
    draw = ImageDraw.Draw(img)
    cx, cy = BIG / 2, BIG / 2 + 14 * S
    scale = 22 * S
    draw_journey_path(draw, cx, cy, scale)
    # Sombra suave del corazon.
    shadow = Image.new("RGBA", (BIG, BIG), (0, 0, 0, 0))
    sdraw = ImageDraw.Draw(shadow)
    draw_heart(sdraw, cx + 6 * S, cy + 8 * S, scale, (61, 44, 38, 70))
    from PIL import ImageFilter
    shadow = shadow.filter(ImageFilter.GaussianBlur(10 * S))
    img = Image.alpha_composite(img, shadow)
    draw = ImageDraw.Draw(img)
    draw_heart(draw, cx, cy, scale, TERRACOTTA, outline=TERRACOTTA_DARK, width=3 * S)
    return img.resize((SIZE, SIZE), Image.LANCZOS)


def build_foreground():
    """Solo el corazon (con camino), fondo transparente y margen seguro para
    el recorte del adaptive icon de Android (~66% de zona segura)."""
    img = Image.new("RGBA", (BIG, BIG), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    cx, cy = BIG / 2, BIG / 2 + 10 * S
    scale = 15 * S   # mas pequeno: el adaptive recorta los bordes
    draw_journey_path(draw, cx, cy, scale)
    draw_heart(draw, cx, cy, scale, TERRACOTTA, outline=TERRACOTTA_DARK, width=2 * S)
    return img.resize((SIZE, SIZE), Image.LANCZOS)


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    build_full().save(os.path.join(OUT_DIR, "app_icon.png"))
    build_foreground().save(os.path.join(OUT_DIR, "app_icon_foreground.png"))
    print("Iconos generados en", OUT_DIR)


if __name__ == "__main__":
    main()
